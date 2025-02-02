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
        
        container.register(MainMapViewController.self) { r in
            let mainMapViewModel = r.resolve(MainMapViewModel.self)!
            return MainMapViewController(viewModel: mainMapViewModel)
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
        }.inObjectScope(.transient)
        
        container.register(WriteNewStoryViewController.self) { (r, story: Story) in
            let writeNewStoryViewModel = r.resolve(WriteNewStoryViewModel.self, argument: story)!
            return WriteNewStoryViewController(viewModel: writeNewStoryViewModel)
        }.inObjectScope(.transient)
        
        container.register(MyStoryViewController.self) { r in
            let myStoryViewModel = r.resolve(MyStoryViewModel.self)!
            return MyStoryViewController(viewModel: myStoryViewModel)
        }
        
        container.register(EditChapterListViewController.self) { (r, storyId: String) in
            let editChapterListViewModel = r.resolve(EditChapterListViewModel.self, argument: storyId)!
            return EditChapterListViewController(viewModel: editChapterListViewModel)
        }
        
        container.register(EditChapterViewController.self) { (resolver, chapter: NestedChapter, rootChapter: NestedChapter) in
            let viewModel = resolver.resolve(EditChapterViewModel.self, arguments: chapter, rootChapter)!
            return EditChapterViewController(viewModel: viewModel)
        }
        
        container.register(EditStepListViewController.self) { (r, chapterId: String, rootChapter: NestedChapter) in
            let viewModel = r.resolve(EditStepListViewModel.self, arguments: chapterId, rootChapter)!
            return EditStepListViewController(viewModel: viewModel)
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
        
        container.register(MainMapViewModel.self) { r in
            return MainMapViewModel()
        }.inObjectScope(.container)
        
        container.register(WriteNewStoryViewModel.self) { r in
            let storyUseCase = r.resolve(StoryUseCaseProtocol.self)!
            let mediaUseCase = r.resolve(MediaUseCaseProtocol.self)!
            let userProfileUseCase = r.resolve(UserProfileUseCaseProtocol.self)!
            return WriteNewStoryViewModel(storyUseCase: storyUseCase, mediaUseCase: mediaUseCase, userProfileUseCase: userProfileUseCase)
        }.inObjectScope(.transient)
        
        container.register(WriteNewStoryViewModel.self) { (r, story: Story) in
            let storyUseCase = r.resolve(StoryUseCaseProtocol.self)!
            let mediaUseCase = r.resolve(MediaUseCaseProtocol.self)!
            let userProfileUseCase = r.resolve(UserProfileUseCaseProtocol.self)!
            return WriteNewStoryViewModel(story: story, storyUseCase: storyUseCase, mediaUseCase: mediaUseCase, userProfileUseCase: userProfileUseCase)
        }.inObjectScope(.transient)
        
        container.register(MyStoryViewModel.self) { r in
            let storyUseCase = r.resolve(StoryUseCaseProtocol.self)!
            return MyStoryViewModel(storyUseCase: storyUseCase)
        }.inObjectScope(.transient)
        
        container.register(UserProfileViewModel.self) { r in
            return UserProfileViewModel()
        }.inObjectScope(.container)
        
        container.register(EditChapterListViewModel.self) { (r, storyId: String) in
            let chapterUseCase = r.resolve(ChapterUseCaseProtocol.self)!
            return EditChapterListViewModel(storyId: storyId, chapterUseCase: chapterUseCase)
        }.inObjectScope(.transient)
        
        container.register(EditChapterViewModel.self) { (r, chapter: NestedChapter, rootChapter: NestedChapter) in
            let chapterUseCase = r.resolve(ChapterUseCaseProtocol.self)!
            let mediaUseCase = r.resolve(MediaUseCaseProtocol.self)!
            let userProfileUseCase = r.resolve(UserProfileUseCaseProtocol.self)!
            return EditChapterViewModel(chapter: chapter, rootChapter: rootChapter, chapterUseCase: chapterUseCase, mediaUseCase: mediaUseCase, userProfileUseCase: userProfileUseCase)
        }.inObjectScope(.transient)
        
        container.register(EditStepListViewModel.self) { (r, chapterId: String, rootChapter: NestedChapter) in
            let storyUseCase = r.resolve(StoryUseCaseProtocol.self)!
            let chapterUseCase = r.resolve(ChapterUseCaseProtocol.self)!
            let stepUseCase = r.resolve(StepUseCaseProtocol.self)!
            let mediaUseCase = r.resolve(MediaUseCaseProtocol.self)!
            return EditStepListViewModel(chapterId: chapterId, rootChapter: rootChapter, storyUseCase: storyUseCase, chapterUseCase: chapterUseCase, stepUseCase: stepUseCase, mediaUseCase: mediaUseCase)
        }.inObjectScope(.transient)
        
        //MARK: - Register UseCases
        container.register(SignInUseCaseProtocol.self) { r in
            let authRepository = r.resolve(AuthenticationRepository.self)!
            let sessionRepository = r.resolve(SessionRepository.self)!
            return SignInUseCase(authRepository: authRepository, sessionRepository: sessionRepository)
        }
        
        container.register(StoryUseCaseProtocol.self) { r in
            let storyRepository = r.resolve(StoryRepository.self)!
            let sessionRepository = r.resolve(SessionRepository.self)!
            return DefaultStoryUseCase(storyRepository: storyRepository, sessionRepository: sessionRepository)
        }
        
        container.register(MediaUseCaseProtocol.self) { r in
            let repository = r.resolve(MediaRepository.self)!
            return DefaultMediaUseCase(repository: repository)
        }
        
        container.register(UserProfileUseCaseProtocol.self) { r in
            let userProfilerepository = r.resolve(UserProfileRepository.self)!
            let sessionRepository = r.resolve(SessionRepository.self)!
            return DefaultUserProfileUseCase(
                userProfileRepository: userProfilerepository,
                sessionRepository: sessionRepository
            )
        }
        
        container.register(ChapterUseCaseProtocol.self) { r in
            let chapterRepository = r.resolve(ChapterRepository.self)!
            return DefaultChapterUseCase(chapterRepository: chapterRepository)
        }
        
        container.register(StepUseCaseProtocol.self) { r in
            let stepRepository = r.resolve(StepRepository.self)!
            return DefaultStepUseCase(stepRepository: stepRepository)
        }
        
        //MARK: - Register Repositories
        container.register(AuthenticationRepository.self) { r in
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
        
        container.register(MediaRepository.self) { r in
            let imgRemoteDataSource = r.resolve(MediaRemoteDataSource.self)!
            return DefaultStorageMediaRepositoryImpl(mediaRemoteDataSource: imgRemoteDataSource)
        }
        
        container.register(UserProfileRepository.self) { r in
            let userProfileDataSource = r.resolve(UserProfileRemoteDataSource.self)!
            return DefaultUserProfileRepositoryImpl(userProfileDataSource: userProfileDataSource)
        }
        
        container.register(SessionRepository.self) { r in
            let localDataSource = r.resolve(LocalDataSource.self)!
            return DefaultSessionRepositoryImpl(localDataSource: localDataSource)
        }
        
        container.register(ChapterRepository.self) { r in
            let chapterRemoteDataSource = r.resolve(ChapterRemoteDataSource.self)!
            let storyRemoteDataSource = r.resolve(StoryRemoteDataSource.self)!
            return DefaultChapterRepositoryImpl(chapterRemoteDataSource: chapterRemoteDataSource, storyRemoteDataSource: storyRemoteDataSource)
        }
        
        container.register(StepRepository.self) { r in
            let stepRemoteDataSource = r.resolve(StepRemoteDataSource.self)!
            return DefaultStepRepositoryImpl(stepRemoteDataSource: stepRemoteDataSource)
        }
        
        //MARK: - Register Data Sources
        container.register(AppleSignRemoteDataSource.self) { _ in AppleSignRemoteDataSourceImpl() }
        container.register(GoogleSignRemoteDataSource.self) { _ in GoogleSignRemoteDataSourceImpl() }
        container.register(KakaoSignRemoteDataSource.self) { _ in KakaoSignRemoteDataSourceImpl() }
        container.register(NaverSignRemoteDataSource.self) { _ in NaverSignRemoteDataSourceImpl() }
        container.register(FirebaseAuthRemoteDataSource.self) { _ in FirebaseAuthRemoteDataSourceImpl() }

        container.register(StoryRemoteDataSource.self) { _ in FirestoreStoryRemoteDataSourceImpl()}
        
        container.register(MediaRemoteDataSource.self) { _ in
            FirebaseStorageMediaRemoteDataSourceImpl()
        }
        
        container.register(UserProfileRemoteDataSource.self) { _ in
            FirestoreUserProfileRemoteDataSourceImpl()
        }
        
        container.register(LocalDataSource.self) { _ in
            UserDefaultsLocalDataSourceImpl()
        }
        
        container.register(ChapterRemoteDataSource.self) { _ in 
            FirestoreChapterRemoteDataSourceImpl()
        }
        
        container.register(StepRemoteDataSource.self) { r in
            let chapterRemoteDataSource = r.resolve(ChapterRemoteDataSource.self)!
            return FirestoreStepRemoteDataSourceImpl(chapterRemoteDataSource: chapterRemoteDataSource)
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
    
    func makeMainMapViewController() -> MainMapViewController {
        return self.container.resolve(MainMapViewController.self)!
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
    
    func makeEditStoryViewController(story: Story) -> WriteNewStoryViewController {
        return self.container.resolve(WriteNewStoryViewController.self, argument: story)!
    }
    
    func makeMyStoryViewController() -> MyStoryViewController {
        return self.container.resolve(MyStoryViewController.self)!
    }
    
    func makeEditChapterListViewController(storyId: String) -> EditChapterListViewController {
        return self.container.resolve(EditChapterListViewController.self, argument: storyId)!
    }
    
    func makeEditChapterViewController(chapter: NestedChapter, rootChapter: NestedChapter) -> EditChapterViewController {
        return self.container.resolve(EditChapterViewController.self, arguments: chapter, rootChapter)!
    }
    
    func makeEditStepListViewController(chapterId: String, rootChapter: NestedChapter) -> EditStepListViewController {
        return self.container.resolve(EditStepListViewController.self, arguments: chapterId, rootChapter)!
    }
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
