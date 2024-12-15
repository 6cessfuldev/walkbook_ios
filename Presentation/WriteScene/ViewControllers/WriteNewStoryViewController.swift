import UIKit
import RxSwift
import RxCocoa

class WriteNewStoryViewController: UIViewController, UITextFieldDelegate {
    
    private let viewModel: WriteNewStoryViewModel
    weak var coordinator: MainFlowCoordinator!
    
    private let disposeBag = DisposeBag()
    
    private var isItemSelected = false
        
    private let actionImageView = UIImageView()
    private let plusIconImageView = UIImageView()
    
    private let titleTextField = PaddedTextField()
    private let separatorLine = UIView()
    private let descriptionTextView = UITextView()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
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
        
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        descriptionTextView.autocorrectionType = .no
        descriptionTextView.spellCheckingType = .no
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
        
        [titleTextField, descriptionTextView].forEach {
            $0.backgroundColor = .white
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titleTextField.placeholder = "Title"
        
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        descriptionTextView.textContainer.lineFragmentPadding = 0
        
        separatorLine.backgroundColor = .lightGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        
        view.addSubview(actionImageView)
        actionImageView.addSubview(plusIconImageView)
        actionImageView.addSubview(loadingIndicator)
        view.addSubview(titleTextField)
        view.addSubview(separatorLine)
        view.addSubview(descriptionTextView)
        descriptionTextView.addSubview(placeholderLabel)
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
            
            titleTextField.topAnchor.constraint(equalTo: actionImageView.bottomAnchor),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            separatorLine.topAnchor.constraint(equalTo: titleTextField.bottomAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionTextView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            
            placeholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: descriptionTextView.trailingAnchor, constant: -8)
        ])
    }
    
    private func bindViewModel() {
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text.orEmpty
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
                    self?.coordinator.showEditChapterListVC()
                case .failure(let error):
                    print("fail: \(error)")
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

extension WriteNewStoryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
