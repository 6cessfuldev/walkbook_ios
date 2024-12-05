import UIKit

protocol WriteNewFlowCoordinatorDependencies {
    func makeWriteNewStoryViewController() -> WriteNewStoryViewController
}

protocol WriteNewFlowCoordinatorDelegate {
    func didLogout()
}

class WriteNewFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: WriteNewFlowCoordinatorDelegate!
    private let dependencies: WriteNewFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,dependencies: WriteNewFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let WriteNewStoryVC = dependencies.makeWriteNewStoryViewController()
//        WriteNewStoryVC.coordinator = self
        self.navigationController.setViewControllers([WriteNewStoryVC], animated: true)
    }
}
