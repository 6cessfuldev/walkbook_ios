import UIKit
import RxSwift

class MainViewController: UITabBarController {
    
    fileprivate var viewModel: AuthenticationViewModel!
    weak var coordinator: MainFlowCoordinator!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
