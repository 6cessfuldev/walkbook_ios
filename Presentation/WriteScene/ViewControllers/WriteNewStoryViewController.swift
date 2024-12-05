import UIKit
import RxSwift
import RxCocoa

class WriteNewStoryViewController: UIViewController {
    
    private let viewModel: WriteNewStoryViewModel
    private let disposeBag = DisposeBag()
    
    private let titleTextField = UITextField()
    private let authorTextField = UITextField()
    private let imageUrlTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let statusLabel = UILabel()
    
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
        view.backgroundColor = .white
        
        [titleTextField, authorTextField, imageUrlTextField, descriptionTextField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titleTextField.placeholder = "Title"
        authorTextField.placeholder = "Author"
        imageUrlTextField.placeholder = "Image URL"
        descriptionTextField.placeholder = "Description"
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        statusLabel.textAlignment = .center
        statusLabel.textColor = .gray
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleTextField)
        view.addSubview(authorTextField)
        view.addSubview(imageUrlTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(submitButton)
        view.addSubview(loadingIndicator)
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            authorTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            authorTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            authorTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            imageUrlTextField.topAnchor.constraint(equalTo: authorTextField.bottomAnchor, constant: 10),
            imageUrlTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            imageUrlTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            descriptionTextField.topAnchor.constraint(equalTo: imageUrlTextField.bottomAnchor, constant: 10),
            descriptionTextField.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextField.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            
            submitButton.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loadingIndicator.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func bindViewModel() {
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
        authorTextField.rx.text.orEmpty
            .bind(to: viewModel.author)
            .disposed(by: disposeBag)
        
        imageUrlTextField.rx.text.orEmpty
            .bind(to: viewModel.imageUrl)
            .disposed(by: disposeBag)
        
        descriptionTextField.rx.text.orEmpty
            .bind(to: viewModel.description)
            .disposed(by: disposeBag)
        
        submitButton.rx.tap
            .bind(to: viewModel.submitTapped)
            .disposed(by: disposeBag)
        
        viewModel.isSubmitting
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.submissionResult
            .drive(onNext: { [weak self] result in
                switch result {
                case .success:
                    self?.statusLabel.text = "Story submitted successfully!"
                    self?.statusLabel.textColor = .green
                case .failure(let error):
                    self?.statusLabel.text = "Failed to submit story: \(error.localizedDescription)"
                    self?.statusLabel.textColor = .red
                }
            })
            .disposed(by: disposeBag)
    }
}
