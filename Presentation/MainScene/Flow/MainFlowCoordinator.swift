import UIKit

protocol MainFlowCoordinatorDependencies {
    func makeMainViewController() -> MainViewController
    func makeExploreViewController() -> ExploreViewController
    func makeExploreFlowCoordinator(navigationController: UINavigationController) -> ExploreFlowCoordinator
}

protocol MainFlowCoordinatorDelegate {
    func didLogout(coordinator: MainFlowCoordinator)
}

class MainFlowCoordinator: Coordinator, ExploreFlowCoordinatorDelegate {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: MainFlowCoordinatorDelegate!
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
        exploreVC.coordinator = exploreCoordinator
        exploreCoordinator.delegate = self
//        exploreCoordinator.start()
        secondNav.viewControllers = [exploreVC]
        secondNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let thirdNav = UINavigationController()
        thirdNav.viewControllers = [WriteViewController()]
        thirdNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus.app"), tag: 2)
        
        let forthNav = UINavigationController()
        forthNav.viewControllers = [SubscribeViewController()]
        forthNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "archivebox"), tag: 3)
        
        let fifthNav = UINavigationController()
        fifthNav.viewControllers = [ProfileViewController()]
        fifthNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person"), tag: 4)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([firstNav, secondNav, thirdNav, forthNav, fifthNav], animated: true)
        
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
        delegate.didLogout(coordinator: self)
    }
}
