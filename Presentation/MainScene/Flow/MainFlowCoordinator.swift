import UIKit

protocol MainFlowCoordinatorDependencies {
    func makeMainViewController() -> MainViewController
}

class MainFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
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
}
