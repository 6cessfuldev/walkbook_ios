import UIKit

protocol SubscribeFlowCoordinatorDependencies {
    func makeSubscribeViewController() -> SubscribeViewController
}

protocol SubscribeFlowCoordinatorDelegate {
    func didLogout()
}

class SubscribeFlowCoordinator: ContentConsumableCoordinator {
    var childCoordinators: [Coordinator] = []
    weak var mainAppFlowCoordinator: MainFlowCoordinator?
    var navigationController: UINavigationController
    var delegate: SubscribeFlowCoordinatorDelegate!
    private let dependencies: SubscribeFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,dependencies: SubscribeFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let subscribeVC = dependencies.makeSubscribeViewController()
        subscribeVC.coordinator = self
        self.navigationController.setViewControllers([subscribeVC], animated: true)
    }
    
    func showContentMain() {
        self.mainAppFlowCoordinator?.showContentMain()
    }
    
    func didLogout() {
        self.delegate.didLogout()
    }
}
