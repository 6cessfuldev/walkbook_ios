import UIKit

protocol ExploreFlowCoordinatorDependencies {
    func makeExploreViewController() -> ExploreViewController
}

protocol ExploreFlowCoordinatorDelegate {
    func didLogout()
}

class ExploreFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: ExploreFlowCoordinatorDelegate!
    private let dependencies: ExploreFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,dependencies: ExploreFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let ExploreVC = dependencies.makeExploreViewController()
        ExploreVC.coordinator = self
        navigationController.setViewControllers([ExploreVC], animated: true)
    }
    
    func didLogout() {
        self.delegate.didLogout()
    }
}
