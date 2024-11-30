import Foundation

class ProfileSceneDIContainer: ProfileFlowCoordinatorDependencies {
    struct Dependencies {
        let authenticationViewModel: AuthenticationViewModel
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeProfileViewController() -> ProfileViewController {
        ProfileViewController()
    }
    
    func makeContentInfoViewController() -> ContentInfoViewController {
        ContentInfoViewController()
    }
}
