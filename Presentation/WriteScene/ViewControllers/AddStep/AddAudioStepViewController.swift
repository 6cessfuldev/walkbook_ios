import UIKit
import AVFoundation
import RxSwift
import CoreLocation

class AddAudioStepViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let recorderManager = AudioRecorderManager()
    private var audioFileURL: URL?
    private var isRecording = false
    private var isPaused: Bool = false
    private var isPlaying: Bool = false
    private var pausedTime: CMTime?
    
    private var audioPlayer: AVPlayer?
    private var audioPlayerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let audioItemView = UIView()
    private var audioItemViewHeightConstraint: NSLayoutConstraint!
    
    private let playButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let timeLabel = UILabel()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = .lightGray
        progress.progressTintColor = .systemBlue
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let locationPickerView = LocationPickerView()
    
    private let bottomView = UIView()
    private let outerBorderView = UIView()
    private let recordButton = UIButton(type: .system)
    
    var onSave: ((_ audioFileURL: URL, _ location: CLLocationCoordinate2D?, _ completion: @escaping (Result<Void, Error>) -> Void) -> Void)?
    
    init(audioFileURL: URL? = nil) {
        self.audioFileURL = audioFileURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    private func setupNavigationBar() {
        let saveBarButton = UIBarButtonItem(
            image: UIImage(systemName: "checkmark.circle"),
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    @objc private func saveButtonTapped() {
        guard let audioFileURL = audioFileURL else {
            showAlert(message: "오디오를 입력해주세요")
            return
        }
        let location = locationPickerView.selectedLocation
        onSave?(audioFileURL, location) { r in
            switch r {
            case .success(()):
                DispatchQueue.main.async {
                    self.handleSubmitSuccess()
                }
            case .failure(let error):
                print("AddAudioStepViewController : \(error)")
                DispatchQueue.main.async {
                    self.showAlert(message: "통신 오류")
                }
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        stackView.addArrangedSubview(audioItemView)
        stackView.addArrangedSubview(locationPickerView)
        view.addSubview(stackView)
        
        view.addSubview(bottomView)
        bottomView.addSubview(outerBorderView)
        outerBorderView.addSubview(recordButton)
        
        setupAudioItemView()
        
        locationPickerView.translatesAutoresizingMaskIntoConstraints = false
        locationPickerView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        bottomView.backgroundColor = UIColor.systemGray6
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        outerBorderView.backgroundColor = .clear
        outerBorderView.layer.borderColor = UIColor.lightGray.cgColor
        outerBorderView.layer.borderWidth = 4
        outerBorderView.layer.cornerRadius = 35
        outerBorderView.translatesAutoresizingMaskIntoConstraints = false
        
        recordButton.setTitle("🎙", for: .normal)
        recordButton.backgroundColor = .systemRed
        recordButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        recordButton.layer.cornerRadius = 30
        recordButton.clipsToBounds = true
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 120),
            
            outerBorderView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            outerBorderView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor, constant: -15),
            outerBorderView.widthAnchor.constraint(equalToConstant: 70),
            outerBorderView.heightAnchor.constraint(equalToConstant: 70),
            
            recordButton.centerXAnchor.constraint(equalTo: outerBorderView.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: outerBorderView.centerYAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 60),
            recordButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAudioItemView() {
        audioItemView.backgroundColor = UIColor.systemGray5
        audioItemView.layer.cornerRadius = 8
        audioItemView.translatesAutoresizingMaskIntoConstraints = false
        
        if(audioFileURL == nil) {
            audioItemViewHeightConstraint = audioItemView.heightAnchor.constraint(equalToConstant: 0)
            audioItemViewHeightConstraint.isActive = true
            audioItemView.isHidden = true
        } else {
            audioItemViewHeightConstraint = audioItemView.heightAnchor.constraint(equalToConstant: 100)
            audioItemViewHeightConstraint.isActive = true
            audioItemView.isHidden = false
        }
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        audioItemView.addSubview(playButton)
        audioItemView.addSubview(deleteButton)
        audioItemView.addSubview(timeLabel)
        audioItemView.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: audioItemView.leadingAnchor, constant: 16),
            playButton.topAnchor.constraint(equalTo: audioItemView.topAnchor, constant: 16),
            
            deleteButton.trailingAnchor.constraint(equalTo: audioItemView.trailingAnchor, constant: -16),
            deleteButton.topAnchor.constraint(equalTo: audioItemView.topAnchor, constant: 16),
            
            timeLabel.centerXAnchor.constraint(equalTo: audioItemView.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: audioItemView.topAnchor, constant: 16),
            
            progressView.leadingAnchor.constraint(equalTo: audioItemView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: audioItemView.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: audioItemView.bottomAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    private func setupBindings() {
        playButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.playAudio()
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.deleteAudio()
            })
            .disposed(by: disposeBag)
        
        recordButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.tapRecording()
            })
            .disposed(by: disposeBag)
    }
    
    private func playAudio() {
        guard let url = audioFileURL else {
            print("Audio URL is nil.")
            return
        }
        
        if url.isFileURL {
            playLocalAudio(url: url)
        } else {
            playRemoteAudio(url: url)
        }
    }
    
    private func playLocalAudio(url: URL) {
        if audioPlayerItem?.asset != AVURLAsset(url: url) {
            audioPlayerItem = AVPlayerItem(url: url)
            audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        }
        
        if isPaused {
            resumeAudio()
        } else if isPlaying {
            pauseAudio()
        } else {
            startAudio()
        }
    }
    
    private func playRemoteAudio(url: URL) {
        audioPlayerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: audioPlayerItem)
        
        if isPaused {
            resumeAudio()
        } else if isPlaying {
            pauseAudio()
        } else {
            startAudio()
        }
    }
    
    private func deleteAudio() {
        guard let url = audioFileURL else { return }
        try? FileManager.default.removeItem(at: url)
        audioFileURL = nil
        audioItemView.isHidden = true
        audioItemViewHeightConstraint.constant = 0
        resetPlayerStatus()
        removeTimeObserver()
        
        UIView.animate(withDuration: 0.3) {
            self.stackView.layoutIfNeeded()
        }
    }
    
    private func resetPlayerStatus() {
        progressView.progress = 0
        timeLabel.text = "00:00"
        isPaused = false
        isPlaying = false
        pausedTime = CMTime.zero
    }
    
    private func tapRecording() {
        
        if !isRecording {
            if(audioFileURL != nil) {
                showRecordingConfirmationDialog()
                return
            }
            recorderManager.requestPermission { [weak self] granted in
                guard granted else { return }
                self?.recorderManager.startRecording()
                self?.isRecording = true
            }
        } else {
            audioFileURL = recorderManager.stopRecording()
            isRecording = false
            audioItemView.isHidden = false
            audioItemViewHeightConstraint.constant = 100
        }
        
        UIView.animate(withDuration: 0.3) {
            self.stackView.layoutIfNeeded()
        }
    }
    
    private func startAudio() {
        guard let player = audioPlayer else { return }
        playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        player.play()
        isPlaying = true
        isPaused = false
        progressView.progress = 0.0
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
            
            guard duration.isFinite && duration > 0 else { return }
            
            self.progressView.progress = Float(currentTime / duration)
            self.timeLabel.text = String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
        }
    }
    
    private func pauseAudio() {
        guard let player = audioPlayer else { return }
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player.pause()
        isPaused = true
        isPlaying = false
        pausedTime = player.currentTime()
        
        removeTimeObserver()
    }
    
    private func resumeAudio() {
        guard let player = audioPlayer, let pausedTime = pausedTime else { return }
        playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        player.seek(to: pausedTime)
        player.play()
        isPaused = false
        isPlaying = true
        self.pausedTime = nil
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
            guard duration.isFinite && duration > 0 else { return }
            
            self.progressView.progress = Float(currentTime / duration)
            self.timeLabel.text = String(format: "%02d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            audioPlayer?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    private func showRecordingConfirmationDialog() {
        let alertController = UIAlertController(
            title: "새로 녹음하시겠습니까?",
            message: "기존 녹음은 삭제됩니다.",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "예", style: .destructive) { [weak self] _ in
            self?.deleteAudio()
            self?.recorderManager.requestPermission { [weak self] granted in
                guard granted else { return }
                self?.recorderManager.startRecording()
                self?.isRecording = true
            }
        }
        
        let noAction = UIAlertAction(title: "아니오", style: .cancel) { _ in
            print("사용자가 기존 녹음을 유지하기로 선택했습니다.")
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    private func handleSubmitSuccess() {
        let alert = UIAlertController(title: "알림", message: "저장 완료", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func audioDidFinishPlaying(notification: Notification) {
        removeTimeObserver()
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        progressView.progress = 0.0
        isPlaying = false
        isPaused = false
    }
}
