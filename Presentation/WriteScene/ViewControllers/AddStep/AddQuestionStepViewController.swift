import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class AddQuestionStepViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    var onSave: ((Step) -> Void)?
    
    private let questionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter the question"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()
    
    private let answerTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter the correct answer"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()
    
    private let optionsTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.text = "Optional: Enter options separated by commas"
        textView.textColor = .lightGray
        return textView
    }()
    
    private let locationSwitch: UISwitch = {
        let locationSwitch = UISwitch()
        return locationSwitch
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Include Location"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let selectLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Location on Map", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        return button
    }()
    
    private var selectedLocation: CLLocationCoordinate2D?
    private var optionsPlaceholder = "Optional: Enter options separated by commas"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        let locationStack = UIStackView(arrangedSubviews: [locationLabel, locationSwitch])
        locationStack.axis = .horizontal
        locationStack.spacing = 8
        
        view.addSubview(questionTextField)
        view.addSubview(answerTextField)
        view.addSubview(optionsTextView)
        view.addSubview(locationStack)
        view.addSubview(selectLocationButton)
        view.addSubview(saveButton)
        
        questionTextField.translatesAutoresizingMaskIntoConstraints = false
        answerTextField.translatesAutoresizingMaskIntoConstraints = false
        optionsTextView.translatesAutoresizingMaskIntoConstraints = false
        locationStack.translatesAutoresizingMaskIntoConstraints = false
       selectLocationButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionTextField.heightAnchor.constraint(equalToConstant: 40),
            
            answerTextField.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 16),
            answerTextField.leadingAnchor.constraint(equalTo: questionTextField.leadingAnchor),
            answerTextField.trailingAnchor.constraint(equalTo: questionTextField.trailingAnchor),
            answerTextField.heightAnchor.constraint(equalToConstant: 40),
            
            optionsTextView.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 16),
            optionsTextView.leadingAnchor.constraint(equalTo: answerTextField.leadingAnchor),
            optionsTextView.trailingAnchor.constraint(equalTo: answerTextField.trailingAnchor),
            optionsTextView.heightAnchor.constraint(equalToConstant: 100),
            
            saveButton.topAnchor.constraint(equalTo: optionsTextView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBindings() {
        // Options TextView placeholder logic
        optionsTextView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] in
                if self?.optionsTextView.text == self?.optionsPlaceholder {
                    self?.optionsTextView.text = ""
                    self?.optionsTextView.textColor = .black
                }
            })
            .disposed(by: disposeBag)
        
        optionsTextView.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                if self?.optionsTextView.text.isEmpty == true {
                    self?.optionsTextView.text = self?.optionsPlaceholder
                    self?.optionsTextView.textColor = .lightGray
                }
            })
            .disposed(by: disposeBag)
        
        // Save button logic
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveStep()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Save Action
    private func saveStep() {
        guard let question = questionTextField.text, !question.isEmpty,
              let answer = answerTextField.text, !answer.isEmpty else {
            showAlert(message: "Please enter both a question and an answer.")
            return
        }
        
        var options: [String]? = nil
        if optionsTextView.text != optionsPlaceholder, !optionsTextView.text.isEmpty {
            options = optionsTextView.text.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        onSave?(Step(id: nil, type: .question(correctAnswer: answer, options: options), location: nil))
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
