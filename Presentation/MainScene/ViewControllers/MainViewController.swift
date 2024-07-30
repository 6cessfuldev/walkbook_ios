import UIKit
import RxSwift

class MainViewController: UIViewController {
    
    fileprivate var viewModel: AuthenticationViewModel!
    var coordinator: Coordinator!
    let disposeBag = DisposeBag()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(idLabel)
        
        NSLayoutConstraint.activate([
            idLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            idLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
//        viewModel.userEmail.accept("Initial email for debugging")
        
        viewModel.userEmail
            .asObservable()
            .map { $0 ?? "No email" }
            .bind(to: idLabel.rx.text)
            .disposed(by: disposeBag)
        }
}
