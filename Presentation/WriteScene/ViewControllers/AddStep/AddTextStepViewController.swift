import UIKit
import RxSwift

class AddTextStepViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let textView = UITextView()
    private let saveButton = UIButton(type: .system)
    
    var onSave: ((Step) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "텍스트 추가"
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            saveButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupBinding() {
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, !self.textView.text.isEmpty else { return }
                self.onSave?(Step(id: nil, type: .text(self.textView.text)))
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
