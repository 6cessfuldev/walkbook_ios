import UIKit

protocol ProfileFlowCoordinatorDependencies {
    func makeProfileViewController() -> ProfileViewController
}

protocol ProfileFlowCoordinatorDelegate {
    func didLogout()
}

class ProfileFlowCoordinator: ContentConsumableCoordinator {
    var childCoordinators: [Coordinator] = []
    weak var mainAppFlowCoordinator: MainFlowCoordinator?
    var navigationController: UINavigationController
    var delegate: ProfileFlowCoordinatorDelegate!
    private let dependencies: ProfileFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,dependencies: ProfileFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let profileVC = dependencies.makeProfileViewController()
        profileVC.coordinator = self
        self.navigationController.setViewControllers([profileVC], animated: true)
    }
    
    func showContentMain() {
        self.mainAppFlowCoordinator?.showContentMain()
    }
    
    func didLogout() {
        self.delegate.didLogout()
    }
}
