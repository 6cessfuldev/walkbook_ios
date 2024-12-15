import UIKit
import RxSwift

class AddStepViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Step Title"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var onSave: ((String) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            titleTextField.widthAnchor.constraint(equalToConstant: 250),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupBinding() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveButtonTapped()
            })
            .disposed(by: disposeBag)
    }
    
    private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        onSave?(title)
        dismiss(animated: true, completion: nil)
    }
}
