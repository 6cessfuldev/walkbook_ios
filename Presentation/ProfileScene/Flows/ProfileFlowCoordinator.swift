import UIKit

protocol ProfileFlowCoordinatorDependencies {
    func makeProfileViewController() -> ProfileViewController
    func makeContentInfoViewController() -> ContentInfoViewController
}

protocol ProfileFlowCoordinatorDelegate {
    func didLogout()
}

class ProfileFowCoordinator: ContentConsumableCoordinator {
    var childCoordinators: [Coordinator] = []
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
        navigationController.setViewControllers([profileVC], animated: true)
    }
    
    func showContentInfo() {
        let contentInfoVC = dependencies.makeContentInfoViewController()
        contentInfoVC.coordinator = self
        navigationController.pushViewController(contentInfoVC, animated: true)
    }
    
    func showContentMain() {
    }
    
    func didLogout() {
        self.delegate.didLogout()
    }
}
