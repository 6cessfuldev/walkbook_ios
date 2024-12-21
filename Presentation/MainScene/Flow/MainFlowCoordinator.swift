import UIKit

protocol MainFlowCoordinatorDependencies {
    func makeMainViewController() -> MainViewController
    func makeExploreFlowCoordinator(navigationController: UINavigationController) -> ExploreFlowCoordinator
    func makeSubscribeFlowCoordinator(navigationController: UINavigationController) -> SubscribeFlowCoordinator
    func makeProfileFlowCoordinator(navigationController: UINavigationController) -> ProfileFlowCoordinator
    func makeContentMainViewController() -> ContentMainViewController
    func makeWriteNewStoryViewController() -> WriteNewStoryViewController
    func makeEditStoryViewController(story: Story) -> WriteNewStoryViewController
    func makeMyStoryViewController() -> MyStoryViewController
    func makeEditChapterListViewController(storyId: String) -> EditChapterListViewController
    func makeEditChapterViewController(chapter: NestedChapter) -> EditChapterViewController
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
        super.init()
        self.navigationController.delegate = self
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
        let subscribeCoordinator = self.dependencies.makeSubscribeFlowCoordinator(navigationController: forthNav)
        subscribeCoordinator.delegate = self
        subscribeCoordinator.mainAppFlowCoordinator = self
        subscribeCoordinator.start()
        forthNav.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "archivebox"), tag: 3)
        
        self.childCoordinators.append(subscribeCoordinator)
        
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
        let writeBottomMenuViewController = WriteBottomMenuViewController()
        writeBottomMenuViewController.coordinator = self
        writeBottomMenuViewController.modalPresentationStyle = .pageSheet
        if let sheet = writeBottomMenuViewController.sheetPresentationController {
            sheet.detents = [
                        .custom(identifier: .init("smallHeight")) { context in
                            return 200
                        }
                    ]
        }
        self.navigationController.present(writeBottomMenuViewController, animated: true, completion: nil)
    }
    
    func dismissBottomModal() {
        self.navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func showContentMain() {
        let contentMainVC = dependencies.makeContentMainViewController()
        self.navigationController.pushViewController(contentMainVC, animated: true)
    }
    
    func showWriteNewStoryVC() {
        let writeNewStoryVC = dependencies.makeWriteNewStoryViewController()
        writeNewStoryVC.coordinator = self
        self.navigationController.pushViewController(writeNewStoryVC, animated: true)
    }
    
    func showEditStoryVC(story: Story) {
        let writeNewStoryVC = dependencies.makeEditStoryViewController(story: story)
        writeNewStoryVC.coordinator = self
        self.navigationController.pushViewController(writeNewStoryVC, animated: true)
    }
    
    func showEditChapterListVC(storyId: String) {
        let editChapterListVC = dependencies.makeEditChapterListViewController(storyId: storyId)
        editChapterListVC.coordinator = self
        self.navigationController.pushViewController(editChapterListVC, animated: true)
    }
    
    func showEditChapterVC(chapter: NestedChapter) {
        let editChapterVC = dependencies.makeEditChapterViewController(chapter: chapter)
        editChapterVC.coordinator = self
        self.navigationController.pushViewController(editChapterVC, animated: true)
    }
    
    func showMyStoryVC() {
        let myStoryVC = dependencies.makeMyStoryViewController()
        myStoryVC.coordinator = self
        self.navigationController.pushViewController(myStoryVC, animated: true)
    }
    
    func replaceWithMyStoryVC() {
        let myStoryVC = dependencies.makeMyStoryViewController()
        myStoryVC.coordinator = self
        
        replaceTopViewController(with: myStoryVC, animated: true)
    }
    
    private func replaceTopViewController(with viewController: UIViewController, animated: Bool) {
        var viewControllers = self.navigationController.viewControllers
        if !viewControllers.isEmpty {
            viewControllers.removeLast()
        }
        viewControllers.append(viewController)
        
        self.navigationController.setViewControllers(viewControllers, animated: animated)
    }
}

extension MainFlowCoordinator: ExploreFlowCoordinatorDelegate {
}

extension MainFlowCoordinator: ProfileFlowCoordinatorDelegate {
    
}

extension MainFlowCoordinator: SubscribeFlowCoordinatorDelegate {
    
}

extension MainFlowCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.first === viewController {
            navigationController.navigationBar.isHidden = true
        } else {
            navigationController.navigationBar.isHidden = false
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.first === viewController {
            navigationController.navigationBar.isHidden = true
        } else {
            navigationController.navigationBar.isHidden = false
        }
    }
}
