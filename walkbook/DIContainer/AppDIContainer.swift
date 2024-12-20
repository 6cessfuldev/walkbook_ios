import Foundation
import Swinject

class AppDIContainer {
    
    let container: Container

    init() {
        container = Container()
        
        //MARK: - Register ViewControllers
        container.register(AuthenticationViewController.self) { r in
            let viewModel = r.resolve(AuthenticationViewModel.self)!
            return AuthenticationViewController(viewModel: viewModel)
        }
        
        container.register(MainViewController.self) { r in
            let viewModel = r.resolve(AuthenticationViewModel.self)!
            return MainViewController(viewModel: viewModel)
        }
        
        container.register(ContentInfoViewController.self) { r in
            return ContentInfoViewController()
        }
        
        container.register(ContentMainViewController.self) { r in
            return ContentMainViewController()
        }
        
        container.register(ExploreViewController.self) { r in
            let authenticationViewModel = r.resolve(AuthenticationViewModel.self)!
            return ExploreViewController(viewModel: authenticationViewModel)
        }
        
        container.register(SubscribeViewController.self) { r in
            return SubscribeViewController()
        }
        
        container.register(ProfileViewController.self) { r in
            let userProfileViewModel = r.resolve(UserProfileViewModel.self)!
            return ProfileViewController(viewModel: userProfileViewModel)
        }
        
        container.register(WriteNewStoryViewController.self) { r in
            let writeNewStoryViewModel = r.resolve(WriteNewStoryViewModel.self)!
            return WriteNewStoryViewController(viewModel: writeNewStoryViewModel)
        }
        
        container.register(MyStoryViewController.self) { r in
            let myStoryViewModel = r.resolve(MyStoryViewModel.self)!
            return MyStoryViewController(viewModel: myStoryViewModel)
        }
        
        container.register(EditChapterListViewController.self) { r in
            let editChapterListViewModel = r.resolve(EditChapterListViewModel.self)!
            return EditChapterListViewController(viewModel: editChapterListViewModel)
        }
        
        container.register(EditChapterViewController.self) { (resolver, chapter: NestedChapter) in
            let viewModel = resolver.resolve(EditChapterViewModel.self, argument: chapter)!
            return EditChapterViewController(viewModel: viewModel)
        }

        
        //MARK: - Register ViewModel
        container.register(AuthenticationViewModel.self) { r in
            let userProfileViewModel = r.resolve(UserProfileViewModel.self)!
            let signInUseCase = r.resolve(SignInUseCaseProtocol.self)!
            return AuthenticationViewModel(
                userProfileViewModel: userProfileViewModel,
                signInUseCase: signInUseCase
            )
        }.inObjectScope(.container)
        
        container.register(WriteNewStoryViewModel.self) { r in
            let storyUseCase = r.resolve(StoryUseCaseProtocol.self)!
            let imageUseCase = r.resolve(ImageUseCaseProtocol.self)!
            let userProfileUseCase = r.resolve(UserProfileUseCaseProtocol.self)!
            return WriteNewStoryViewModel(storyUseCase: storyUseCase, imageUseCase: imageUseCase, userProfileUseCase: userProfileUseCase)
        }.inObjectScope(.transient)
        
        container.register(MyStoryViewModel.self) { r in
            let storyUseCase = r.resolve(StoryUseCaseProtocol.self)!
            return MyStoryViewModel(storyUseCase: storyUseCase)
        }.inObjectScope(.transient)
        
        container.register(UserProfileViewModel.self) { r in
            return UserProfileViewModel()
        }.inObjectScope(.container)
        
        container.register(EditChapterListViewModel.self) { r in
            return EditChapterListViewModel()
        }.inObjectScope(.transient)
        
        container.register(EditChapterViewModel.self) { (r, chapter: NestedChapter) in
            let imageUseCase = r.resolve(ImageUseCaseProtocol.self)!
            return EditChapterViewModel(chapter: chapter, imageUseCase: imageUseCase)
        }.inObjectScope(.transient)
        
        //MARK: - Register UseCases
        container.register(SignInUseCaseProtocol.self) { r in
            let authRepository = r.resolve(AuthenticationRepository.self)!
            let sessionRepository = r.resolve(SessionRepository.self)!
            return SignInUseCase(authRepository: authRepository, sessionRepository: sessionRepository)
        }
        
        container.register(StoryUseCaseProtocol.self) { r in
            let repository = r.resolve(StoryRepository.self)!
            return DefaultStoryUseCase(repository: repository)
        }
        
        container.register(ImageUseCaseProtocol.self) { r in
            let repository = r.resolve(ImageRepository.self)!
            return DefaultImageUseCase(repository: repository)
        }
        
        container.register(UserProfileUseCaseProtocol.self) { r in
            let userProfilerepository = r.resolve(UserProfileRepository.self)!
            let sessionRepository = r.resolve(SessionRepository.self)!
            return DefaultUserProfileUseCase(
                userProfileRepository: userProfilerepository,
                sessionRepository: sessionRepository
                
            )
        }
        
        //MARK: - Register Repositories
        container.register(AuthenticationRepository.self) { r in
            let sessionRepository = r.resolve(SessionRepository.self)!
            let googleDataSource = r.resolve(GoogleSignRemoteDataSource.self)!
            let kakaoDataSource = r.resolve(KakaoSignRemoteDataSource.self)!
            let naverDataSource = r.resolve(NaverSignRemoteDataSource.self)!
            let appleDataSource = r.resolve(AppleSignRemoteDataSource.self)!
            let firebaseAuthDataSource = r.resolve(FirebaseAuthRemoteDataSource.self)!
            let userProfileDataSource = r.resolve(UserProfileRemoteDataSource.self)!
            
            return FirebaseAuthenticationRepositoryImpl(
                googleSignRemoteDataSource: googleDataSource,
                kakaoSignRemoteDataSource: kakaoDataSource,
                naverSignRemoteDataSource: naverDataSource,
                appleSignRemoteDataSource: appleDataSource,
                firebaseAuthRemoteDataSource: firebaseAuthDataSource,
                userProfileRemoteDataSource: userProfileDataSource
            )
        }
        
        container.register(StoryRepository.self) { r in
            let storyRemoteDataSource = r.resolve(StoryRemoteDataSource.self)!
            
            return DefaultStoryRepositoryImpl(storyRemoteDataSource: storyRemoteDataSource)
        }
        
        container.register(ImageRepository.self) { r in
            let imgRemoteDataSource = r.resolve(ImageRemoteDataSource.self)!
            return DefaultStorageImageRepositoryImpl(imageRemoteDataSource: imgRemoteDataSource)
        }
        
        container.register(UserProfileRepository.self) { r in
            let userProfileDataSource = r.resolve(UserProfileRemoteDataSource.self)!
            return DefaultUserProfileRepositoryImpl(userProfileDataSource: userProfileDataSource)
        }
        
        container.register(SessionRepository.self) { r in
            let localDataSource = r.resolve(LocalDataSource.self)!
            return DefaultSessionRepositoryImpl(localDataSource: localDataSource)
        }
        
        //MARK: - Register Data Sources
        container.register(AppleSignRemoteDataSource.self) { _ in AppleSignRemoteDataSourceImpl() }
        container.register(GoogleSignRemoteDataSource.self) { _ in GoogleSignRemoteDataSourceImpl() }
        container.register(KakaoSignRemoteDataSource.self) { _ in KakaoSignRemoteDataSourceImpl() }
        container.register(NaverSignRemoteDataSource.self) { _ in NaverSignRemoteDataSourceImpl() }
        container.register(FirebaseAuthRemoteDataSource.self) { _ in FirebaseAuthRemoteDataSourceImpl() }

        container.register(StoryRemoteDataSource.self) { _ in FirestoreStoryRemoteDataSourceImpl()}
        
        container.register(ImageRemoteDataSource.self) { _ in
            FirebaseStorageImageRemoteDataSourceImpl()
        }
        
        container.register(UserProfileRemoteDataSource.self) { _ in
            FirestoreUserProfileRemoteDataSourceImpl()
        }
        
        container.register(LocalDataSource.self) { _ in
            UserDefaultsLocalDataSourceImpl()
        }
    }
}

//MARK: - AuthenticationFlowCoordinator

extension AppDIContainer {
    func makeAuthenticationFlowCoordinator(navigationController: UINavigationController) -> AuthenticationFlowCoordinator {
        return AuthenticationFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension AppDIContainer: AuthenticationFlowCoordinatorDependencies {
    func makeAuthenticationViewController() -> AuthenticationViewController {
        container.resolve(AuthenticationViewController.self)!
    }
}

//MARK: - MainFlowCoordinator

extension AppDIContainer {
    func makeMainFlowCoordinator(navigationController: UINavigationController) -> MainFlowCoordinator {
        return MainFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
    
    func makeContentMainViewController() -> ContentMainViewController {
        return container.resolve(ContentMainViewController.self)!
    }
}

//MARK: - MainFlowCoordinatorDependencies

extension AppDIContainer: MainFlowCoordinatorDependencies {
    func makeMainViewController() -> MainViewController {
        return container.resolve(MainViewController.self)!
    }
    
    func makeExploreFlowCoordinator(navigationController: UINavigationController) -> ExploreFlowCoordinator {
        return ExploreFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
    
    func makeSubscribeFlowCoordinator(navigationController: UINavigationController) -> SubscribeFlowCoordinator {
        return SubscribeFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
    
    func makeProfileViewController() -> ProfileViewController {
        return self.container.resolve(ProfileViewController.self)!
    }
    
    func makeProfileFlowCoordinator(navigationController: UINavigationController) -> ProfileFlowCoordinator {
        return ProfileFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
    
    func makeWriteNewStoryViewController() -> WriteNewStoryViewController {
        return self.container.resolve(WriteNewStoryViewController.self)!
    }
    
    func makeMyStoryViewController() -> MyStoryViewController {
        return self.container.resolve(MyStoryViewController.self)!
    }
    
    func makeEditChapterListViewController() -> EditChapterListViewController {
        return self.container.resolve(EditChapterListViewController.self)!
    }
    
    func makeEditChapterViewController(chapter: NestedChapter) -> EditChapterViewController {
        return self.container.resolve(EditChapterViewController.self, argument: chapter)!
    }
}

//MARK: - ChildCoordinator's dependencies

extension AppDIContainer {
    
}

//MARK: - ExploreFlowCoordinatorDependencies

extension AppDIContainer: ExploreFlowCoordinatorDependencies {
    func makeContentInfoViewController() -> ContentInfoViewController {
        return container.resolve(ContentInfoViewController.self)!
    }
    
    func makeExploreViewController() -> ExploreViewController {
        return container.resolve(ExploreViewController.self)!
    }
}

//MARK: - ProfileFlowCoordinatorDependencies

extension AppDIContainer: ProfileFlowCoordinatorDependencies {
    
}

//MARK: - SubscribeFlowCoordinatorDependencies

extension AppDIContainer: SubscribeFlowCoordinatorDependencies {
    func makeSubscribeViewController() -> SubscribeViewController {
        return container.resolve(SubscribeViewController.self)!
    }
    
    
}
