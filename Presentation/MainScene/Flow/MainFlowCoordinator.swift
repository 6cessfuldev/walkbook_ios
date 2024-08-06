import UIKit

protocol MainFlowCoordinatorDependencies {
    func makeMainViewController() -> MainViewController
}

protocol MainFlowCoordinatorDelegate {
    func didLogout(coordinator: MainFlowCoordinator)
}

class MainFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: MainFlowCoordinatorDelegate!
    private let dependencies: MainFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,dependencies: MainFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let mainVC = dependencies.makeMainViewController()
        mainVC.coordinator = self
        navigationController.setViewControllers([mainVC], animated: true)
    }
    
    func didLogout() {
        delegate.didLogout(coordinator: self)
    }
}
