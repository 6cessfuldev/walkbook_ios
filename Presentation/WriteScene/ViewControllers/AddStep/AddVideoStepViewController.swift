import UIKit
import AVKit
import RxSwift
import RxCocoa

class AddVideoStepViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let videoURLSubject = PublishSubject<URL>()
    private var selectedVideoURL: URL?
    
    var onSave: ((Step) -> Void)?
    
    private let videoPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let selectVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Video", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playerLayer = AVPlayerLayer()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        videoPreviewView.translatesAutoresizingMaskIntoConstraints = false
        playerLayer.videoGravity = .resizeAspectFill
        videoPreviewView.layer.addSublayer(playerLayer)
        
        view.addSubview(videoPreviewView)
        view.addSubview(selectVideoButton)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            videoPreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            videoPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            videoPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            videoPreviewView.heightAnchor.constraint(equalToConstant: 200),
            
            selectVideoButton.topAnchor.constraint(equalTo: videoPreviewView.bottomAnchor, constant: 20),
            selectVideoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: selectVideoButton.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBindings() {
        selectVideoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentVideoPicker()
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let videoURL = self.selectedVideoURL else {
                    self?.showAlert("Please select a video first.")
                    return
                }
                self.onSave?(Step(id: nil, type: .video(videoURL.absoluteString), location: nil))
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        videoURLSubject
            .subscribe(onNext: { [weak self] url in
                self?.playVideo(with: url)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Video Picker
    private func presentVideoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"] // 동영상만 선택
        picker.delegate = self
        picker.videoQuality = .typeMedium
        present(picker, animated: true, completion: nil)
    }
    
    private func playVideo(with url: URL) {
        selectedVideoURL = url
        let player = AVPlayer(url: url)
        playerLayer.player = player
        player.play()
        playerLayer.frame = videoPreviewView.bounds
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddVideoStepViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            videoURLSubject.onNext(videoURL)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
