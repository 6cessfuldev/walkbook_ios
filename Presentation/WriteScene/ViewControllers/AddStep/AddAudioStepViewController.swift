import UIKit
import AVFAudio
import RxSwift
import CoreLocation

class AddAudioStepViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let recorderManager = AudioRecorderManager()
    private var audioFileURL: URL?
    private var isRecording = false
    private var isPaused: Bool = false
    private var isPlaying: Bool = false
    private var pausedTime: TimeInterval?
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    private let audioItemView = UIView()
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
    
    private let bottomView = UIView()
    private let outerBorderView = UIView()
    private let recordButton = UIButton(type: .system)
    
    var onSave: ((_ audioFileURL: URL, _ location: CLLocationCoordinate2D?, _ completion: @escaping (Result<Void, Error>) -> Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        audioItemView.backgroundColor = UIColor.systemGray5
        audioItemView.layer.cornerRadius = 8
        audioItemView.translatesAutoresizingMaskIntoConstraints = false
        audioItemView.isHidden = true
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .center
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        recordButton.addTarget(self, action: #selector(tapRecording), for: .touchUpInside)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(audioItemView)
        audioItemView.addSubview(playButton)
        audioItemView.addSubview(deleteButton)
        audioItemView.addSubview(timeLabel)
        audioItemView.addSubview(progressView)
        
        view.addSubview(bottomView)
        bottomView.addSubview(outerBorderView)
        outerBorderView.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            audioItemView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            audioItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            audioItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            audioItemView.heightAnchor.constraint(equalToConstant: 100),
            
            playButton.leadingAnchor.constraint(equalTo: audioItemView.leadingAnchor, constant: 16),
            playButton.topAnchor.constraint(equalTo: audioItemView.topAnchor, constant: 16),
            
            deleteButton.trailingAnchor.constraint(equalTo: audioItemView.trailingAnchor, constant: -16),
            deleteButton.topAnchor.constraint(equalTo: audioItemView.topAnchor, constant: 16),
            
            timeLabel.centerXAnchor.constraint(equalTo: audioItemView.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: audioItemView.topAnchor, constant: 16),
            
            progressView.leadingAnchor.constraint(equalTo: audioItemView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: audioItemView.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: audioItemView.bottomAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
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
        guard let url = audioFileURL else { return }
        do {
            if(audioPlayer?.url != url) {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
            }
            
            if(isPaused) {
                resumeAudio()
            } else if(isPlaying) {
                pauseAudio()
            } else {
                startAudio()
            }
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    private func deleteAudio() {
        guard let url = audioFileURL else { return }
        try? FileManager.default.removeItem(at: url)
        audioFileURL = nil
        audioItemView.isHidden = true
    }
    
    @objc private func tapRecording() {
        
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
        }
    }
    
    private func startAudio() {
        guard let player = audioPlayer else { return }
        playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        player.play()
        progressView.progress = 0.0
        timer?.invalidate()
        isPlaying = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.progressView.progress = Float(player.currentTime / player.duration)
            self.timeLabel.text = String(format: "%02d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
        }
    }
    
    private func pauseAudio() {
        guard let player = audioPlayer, timer != nil else { return }
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player.pause()
        timer?.invalidate()
        timer = nil
        isPaused = true
        isPlaying = false
        self.pausedTime = player.currentTime
    }
    
    private func resumeAudio() {
        guard let player = audioPlayer, let pausedTime = pausedTime else { return }
        
        playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        player.currentTime = pausedTime
        player.play()
        isPaused = false
        isPlaying = true
        self.pausedTime = nil
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            self.progressView.progress = Float(player.currentTime / player.duration)
            self.timeLabel.text = String(format: "%02d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
        }
    }
    
    private func showRecordingConfirmationDialog() {
        let alertController = UIAlertController(
            title: "새로 녹음하시겠습니까?",
            message: "기존 녹음은 삭제됩니다.",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "예", style: .destructive) { [weak self] _ in
            self?.audioItemView.isHidden = true
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
}

extension AddAudioStepViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        progressView.progress = 0.0
        isPlaying = false
    }
}
