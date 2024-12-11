import UIKit
import RxSwift
import RxCocoa

class WriteNewStoryViewController: UIViewController {
    
    private let viewModel: WriteNewStoryViewModel
    private let disposeBag = DisposeBag()
    
    private var isItemSelected = false
        
    private let actionImageView = UIImageView()
    private let plusIconImageView = UIImageView()
    
    private let titleTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let submitButton = UIBarButtonItem(
        image: UIImage(systemName: "paperplane.fill"),
        style: .done,
        target: nil,
        action: nil
    )
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: WriteNewStoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        navigationItem.rightBarButtonItem = submitButton
        
        actionImageView.contentMode = .scaleAspectFit
        actionImageView.isUserInteractionEnabled = true
        actionImageView.backgroundColor = .backgroundSecondary
        actionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        plusIconImageView.image = UIImage(systemName: "plus.circle")
        plusIconImageView.contentMode = .scaleAspectFit
        plusIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [titleTextField, descriptionTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titleTextField.placeholder = "Title"
        descriptionTextField.placeholder = "Description"
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        
        view.addSubview(actionImageView)
        actionImageView.addSubview(plusIconImageView)
        actionImageView.addSubview(loadingIndicator)
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            actionImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            actionImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionImageView.heightAnchor.constraint(equalToConstant: 300),
            
            plusIconImageView.centerXAnchor.constraint(equalTo: actionImageView.centerXAnchor),
            plusIconImageView.centerYAnchor.constraint(equalTo: actionImageView.centerYAnchor),
            plusIconImageView.widthAnchor.constraint(equalToConstant: 50),
            plusIconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: plusIconImageView.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: plusIconImageView.centerXAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: actionImageView.bottomAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            descriptionTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
        ])
    }
    
    private func bindViewModel() {
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
        descriptionTextField.rx.text.orEmpty
            .bind(to: viewModel.description)
            .disposed(by: disposeBag)
        
        submitButton.rx.tap
            .bind(to: viewModel.submitTapped)
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        actionImageView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.presentImagePicker()
            }
            .disposed(by: disposeBag)
        
        viewModel.selectedImage
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }
            .drive(onNext: { [weak self] image in
                self?.actionImageView.image = image
                if(self?.isItemSelected == false) {
                    self?.isItemSelected = true
                    self?.plusIconImageView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isSubmitting
                .drive(onNext: { [weak self] isSubmitting in
                    guard let self = self else { return }
                    if isSubmitting {
                        self.loadingIndicator.startAnimating()
                        self.plusIconImageView.isHidden = true
                    } else {
                        self.loadingIndicator.stopAnimating()
                        self.plusIconImageView.isHidden = false
                    }
                })
                .disposed(by: disposeBag)
        
        viewModel.submissionResult
            .drive(onNext: { [weak self] result in
                switch result {
                case .success:
                    print("good")
                case .failure(let error):
                    print("fail")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
}

extension WriteNewStoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.selectedImage.accept(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
