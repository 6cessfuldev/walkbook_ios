import UIKit
import RxSwift

class AddAudioStepViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let textField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    var onSave: ((Step) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "음성 추가"
        
        textField.placeholder = "음원 URL을 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            textField.widthAnchor.constraint(equalToConstant: 300),
            
            saveButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBinding() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let text = self.textField.text, !text.isEmpty else { return }
                self.onSave?(Step(id: nil, type: .text(text)))
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
