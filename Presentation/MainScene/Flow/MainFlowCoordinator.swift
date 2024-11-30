import UIKit

protocol MainFlowCoordinatorDependencies {
    func makeMainViewController() -> MainViewController
    func makeExploreViewController() -> ExploreViewController
    func makeExploreFlowCoordinator(navigationController: UINavigationController) -> ExploreFlowCoordinator
    func makeContentMainViewController() -> ContentMainViewController
}

protocol MainFlowCoordinatorDelegate: AnyObject {
    func didLogout(coordinator: MainFlowCoordinator)
}

class MainFlowCoordinator: NSObject, Coordinator, ExploreFlowCoordinatorDelegate, UITabBarControllerDelegate {
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
        
        let secondNav = UINavigationController()
        let exploreVC = makeExploreViewController()
        let exploreCoordinator = makeExploreFlowCoordinator(navigationController: secondNav)
        exploreCoordinator.delegate = self
        exploreCoordinator.mainAppFlowCoordinator = self
        exploreVC.coordinator = exploreCoordinator
        
        
        secondNav.viewControllers = [exploreVC]
        secondNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
//        let thirdNav = UINavigationController()
//        thirdNav.viewControllers = [WriteViewController()]
//        thirdNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus.app"), tag: 2)
        
        let placeholderVC = UIViewController()
        placeholderVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus.app"), tag: 2)
        
        let forthNav = UINavigationController()
        forthNav.viewControllers = [SubscribeViewController()]
        forthNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "archivebox"), tag: 3)
        
        let fifthNav = UINavigationController()
        fifthNav.viewControllers = [ProfileViewController()]
        fifthNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person"), tag: 4)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([firstNav, secondNav, placeholderVC, forthNav, fifthNav], animated: true)
        tabBarController.delegate = self
        
        childCoordinators.append(exploreCoordinator)
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    func makeExploreViewController() -> ExploreViewController {
        dependencies.makeExploreViewController()
    }
    
    func makeExploreFlowCoordinator(navigationController: UINavigationController) -> ExploreFlowCoordinator {
        dependencies.makeExploreFlowCoordinator(navigationController: navigationController)
    }
    
    func didLogout() {
        delegate?.didLogout(coordinator: self)
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
        navigationController.present(writeViewController, animated: true, completion: nil)
    }
    
    func showContentMain() {
        let contentMainVC = dependencies.makeContentMainViewController()
        navigationController.navigationBar.isHidden = false
        navigationController.pushViewController(contentMainVC, animated: true)
    }
    
}
