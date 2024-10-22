import UIKit
import RxSwift

class ExploreViewController: UIViewController {
    
    fileprivate var viewModel: AuthenticationViewModel!
    weak var coordinator: ExploreFlowCoordinator!
    let disposeBag = DisposeBag()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("content", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MainViewController deinitialized: \(self)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
        view.addSubview(idLabel)
        view.addSubview(contentButton)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            idLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            idLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentButton.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: contentButton.bottomAnchor, constant: 20)
        ])
        
        self.navigationController?.isNavigationBarHidden = false
        
        viewModel.userEmail
            .asObservable()
            .map { $0 ?? "No email" }
            .bind(to: idLabel.rx.text)
            .disposed(by: disposeBag)
        
        contentButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator.showContentInfo()
            })
            .disposed(by: disposeBag)
        
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.userEmail.accept(nil)
                self?.coordinator.didLogout()
            })
            .disposed(by: disposeBag)
    }
}
