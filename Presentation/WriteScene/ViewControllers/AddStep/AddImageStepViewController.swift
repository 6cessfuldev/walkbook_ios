import UIKit
import RxSwift
import CoreLocation

class AddImageStepViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let disposeBag = DisposeBag()
    private let imageView = UIImageView()
    private let selectImageButton = UIButton(type: .system)
    private let locationPickerView = LocationPickerView()
    
    var onSave: ((_ image: UIImage, _ location: CLLocationCoordinate2D?, _ completion: @escaping (Result<Void, Error>) -> Void) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
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
    
    private func setupUI() {
        view.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        selectImageButton.setTitle("이미지 선택", for: .normal)
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        locationPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(selectImageButton)
        view.addSubview(locationPickerView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            
            selectImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            locationPickerView.topAnchor.constraint(equalTo: selectImageButton.bottomAnchor, constant: 16),
            locationPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationPickerView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    private func setupBindings() {
        selectImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentImagePicker()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func saveButtonTapped() {
        guard let image = imageView.image else {
            showAlert(message: "이미지를 입력해주세요")
            return
        }
        let location = locationPickerView.selectedLocation
        onSave?(image, location) { r in
            switch r {
            case .success(()):
                DispatchQueue.main.async {
                    self.handleSubmitSuccess()
                }
            case .failure(let error):
                print("AddTextStepViewController : \(error)")
                DispatchQueue.main.async {
                    self.showAlert(message: "통신 오류")
                }
            }
            
        }
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
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
