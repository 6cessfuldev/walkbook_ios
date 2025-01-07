import UIKit
import RxSwift
import RxCocoa

class EditChapterViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    private let viewModel: EditChapterViewModel
    weak var coordinator: MainFlowCoordinator!
    
    private let disposeBag = DisposeBag()
        
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
    
    private let loadingOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let submitButton = UIBarButtonItem(
        image: UIImage(systemName: "paperplane.fill"),
        style: .done,
        target: nil,
        action: nil
    )
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private let editStepsButton = EditStepsButton()
    
    // MARK: - Lifecycle
    init(viewModel: EditChapterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        titleTextField.delegate = self
        descriptionTextView.autocorrectionType = .no
        descriptionTextView.spellCheckingType = .no
        
        navigationItem.title = "챕터 내용"
        
        editStepsButton.onTap = { [weak self] in
            guard let chapterId = self?.viewModel.getChapterId() else {
                print("initial chapter doesn't have id")
                return
            }
            guard let rootChapter = self?.viewModel.rootChapter else {
                print("doesn't have root Chapter")
                return
            }
            self?.coordinator.showEditStepListVC(chapterId: chapterId, rootChapter: rootChapter)
        }
    }
    
    // MARK: - UI Setup
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
        view.addSubview(editStepsButton)
        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            actionImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            actionImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionImageView.heightAnchor.constraint(equalToConstant: 300),
            
            plusIconImageView.centerXAnchor.constraint(equalTo: actionImageView.centerXAnchor),
            plusIconImageView.centerYAnchor.constraint(equalTo: actionImageView.centerYAnchor),
            plusIconImageView.widthAnchor.constraint(equalToConstant: 50),
            plusIconImageView.heightAnchor.constraint(equalToConstant: 50),
            
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
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: descriptionTextView.trailingAnchor, constant: -8),
            
            editStepsButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            editStepsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            editStepsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            editStepsButton.heightAnchor.constraint(equalToConstant: 80),
            
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.title
            .asDriver()
            .distinctUntilChanged()
            .drive(titleTextField.rx.text)
            .disposed(by: disposeBag)
        
        titleTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.description
            .asDriver()
            .distinctUntilChanged()
            .drive(descriptionTextView.rx.text)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text.orEmpty
            .distinctUntilChanged()
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
            })
            .disposed(by: disposeBag)
        
        viewModel.isSubmitting.asDriver()
            .drive(onNext: { [weak self] isSubmitting in
                guard let self = self else { return }
                if isSubmitting {
                    self.loadingOverlay.isHidden = false
                    self.loadingIndicator.startAnimating()
                    self.plusIconImageView.isHidden = true
                } else {
                    self.loadingOverlay.isHidden = true
                    self.loadingIndicator.stopAnimating()
                    self.plusIconImageView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.alertMessage
            .subscribe(onNext: { [weak self] message in
                let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
//    
//    private func getStep(by: String) -> Step {
//        return Step(id: nil, type: .text("Test"))
//    }
}

extension EditChapterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.selectedImage.accept(image)
            viewModel.uploadImage()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
