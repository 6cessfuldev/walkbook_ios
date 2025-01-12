import UIKit
import RxSwift
import CoreLocation
import GoogleMaps

class AddTextStepViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let initText: String?
    private let initLocation: CLLocationCoordinate2D?
    
    private let textView = UITextView()
    private let locationPickerView = LocationPickerView()
    
    var onSave: ((_ text: String, _ location: CLLocationCoordinate2D?,  _ completion: @escaping (Result<Void, Error>) -> Void) -> Void)?
    
    init(text: String? = nil, location: CLLocationCoordinate2D? = nil) {
        initText = text
        initLocation = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupInitialData()
    }
    
    private func setupInitialData() {
        textView.text = initText
        
        if(initLocation != nil) {
            locationPickerView.locationSwitch.setOn(true, animated: false)
            locationPickerView.locationSwitch.sendActions(for: .valueChanged)
            locationPickerView.mapView.animate(toLocation: initLocation!)
        }
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
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        locationPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        view.addSubview(locationPickerView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            locationPickerView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            locationPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationPickerView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    @objc private func saveButtonTapped() {
        guard !textView.text.isEmpty else {
            showAlert(message: "텍스트를 입력해주세요")
            return
        }
        let location = locationPickerView.selectedLocation
        onSave?(textView.text, location) { r in
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
}

