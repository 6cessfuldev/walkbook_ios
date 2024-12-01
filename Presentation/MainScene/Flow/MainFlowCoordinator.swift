import UIKit

protocol MainFlowCoordinatorDependencies {
    func makeMainViewController() -> MainViewController
    func makeExploreFlowCoordinator(navigationController: UINavigationController) -> ExploreFlowCoordinator
    func makeContentMainViewController() -> ContentMainViewController
    func makeProfileFlowCoordinator(navigationController: UINavigationController) -> ProfileFlowCoordinator
}

protocol MainFlowCoordinatorDelegate: AnyObject {
    func didLogout(coordinator: MainFlowCoordinator)
}

class MainFlowCoordinator: NSObject, Coordinator, UITabBarControllerDelegate {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: MainFlowCoordinatorDelegate?
    private let dependencies: MainFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,dependencies: MainFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let firstNav = UINavigationController()
        firstNav.viewControllers = [MainMapViewController()]
        firstNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "map.fill"), tag: 0)
        
        // SecondTab
        let secondNav = UINavigationController()
        let exploreCoordinator = self.dependencies.makeExploreFlowCoordinator(navigationController: secondNav)
        exploreCoordinator.delegate = self
        exploreCoordinator.mainAppFlowCoordinator = self
        exploreCoordinator.start()
        secondNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        self.childCoordinators.append(exploreCoordinator)
        
        let placeholderVC = UIViewController()
        placeholderVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus.app"), tag: 2)
        
        let forthNav = UINavigationController()
        forthNav.viewControllers = [SubscribeViewController()]
        forthNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "archivebox"), tag: 3)
        
        let fifthNav = UINavigationController()
        let profileCoordinator = self.dependencies.makeProfileFlowCoordinator(navigationController: fifthNav)
        profileCoordinator.delegate = self
        profileCoordinator.mainAppFlowCoordinator = self
        profileCoordinator.start()
        fifthNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person"), tag: 4)
                
        self.childCoordinators.append(profileCoordinator)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([firstNav, secondNav, placeholderVC, forthNav, fifthNav], animated: true)
        tabBarController.delegate = self
        
        
        self.navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    func didLogout() {
        self.delegate?.didLogout(coordinator: self)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = tabBarController.viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            showBottomModal()
            return false
        }
        
        return true
    }
    
    private func showBottomModal() {
        let writeViewController = WriteViewController()
        writeViewController.modalPresentationStyle = .pageSheet
        if let sheet = writeViewController.sheetPresentationController {
            sheet.detents = [
                        .custom(identifier: .init("smallHeight")) { context in
                            return 200
                        }
                    ]
        }
        self.navigationController.present(writeViewController, animated: true, completion: nil)
    }
    
    func showContentMain() {
        let contentMainVC = dependencies.makeContentMainViewController()
        self.navigationController.navigationBar.isHidden = false
        self.navigationController.setNavigationBarHidden(false, animated: false)
        self.navigationController.pushViewController(contentMainVC, animated: true)
        self.navigationController.delegate = self
    }
}

extension MainFlowCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if !(navigationController.viewControllers.contains { $0 is ContentMainViewController }) {
            self.navigationController.setNavigationBarHidden(true, animated: false)
        }
    }
}

extension MainFlowCoordinator: ExploreFlowCoordinatorDelegate {
}

extension MainFlowCoordinator: ProfileFlowCoordinatorDelegate {
    
}
