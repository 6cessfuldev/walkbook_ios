//
//  AppDIContainer.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//

import Foundation
import Swinject

class AppDIContainer {
    
    let container: Container

    init() {
        container = Container()

        // Register ViewControllers
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
        
        // Register ViewModel
        container.register(AuthenticationViewModel.self) { r in
            let userProfileViewModel = r.resolve(UserProfileViewModel.self)!
            let googleSignInUseCase = r.resolve(GoogleSignInUseCaseProtocol.self)!
            let kakaoSignInUsecase = r.resolve(KakaoSignInUseCaseProtocol.self)!
            let naverSignInUsecase = r.resolve(NaverSignInUseCaseProtocol.self)!
            let appleSignInUseCase = r.resolve(AppleSignInUseCaseProtocol.self)!
            return AuthenticationViewModel(
                userProfileViewModel: userProfileViewModel,
                googleSignInUseCase: googleSignInUseCase,
                kakaoSignInUseCase: kakaoSignInUsecase,
                naverSignInUseCase: naverSignInUsecase,
                appleSignInUseCase: appleSignInUseCase
            )
        }.inObjectScope(.container)
        
        container.register(WriteNewStoryViewModel.self) { r in
            let storyUseCase = r.resolve(StoryUseCaseProtocol.self)!
            let imageUseCase = r.resolve(ImageUseCaseProtocol.self)!
            return WriteNewStoryViewModel(storyUseCase: storyUseCase, imageUseCase: imageUseCase)
        }.inObjectScope(.transient)
        
        container.register(MyStoryViewModel.self) { r in
            let storyUseCase = r.resolve(StoryUseCaseProtocol.self)!
            return MyStoryViewModel(storyUseCase: storyUseCase)
        }.inObjectScope(.transient)
        
        container.register(UserProfileViewModel.self) { r in
            return UserProfileViewModel()
        }.inObjectScope(.container)
        
        // Register UseCases
        container.register(GoogleSignInUseCaseProtocol.self) { r in
            let repository = r.resolve(AuthenticationRepository.self)!
            return GoogleSignInUseCase(repository: repository)
        }
        
        container.register(KakaoSignInUseCaseProtocol.self) { r in
            let repository = r.resolve(AuthenticationRepository.self)!
            return KakaoSignInUseCase(repository: repository)
        }
        
        container.register(NaverSignInUseCaseProtocol.self) { r in
            let repository = r.resolve(AuthenticationRepository.self)!
            return NaverSignInUseCase(repository: repository)
        }
        
        container.register(AppleSignInUseCaseProtocol.self) { r in
            let repository = r.resolve(AuthenticationRepository.self)!
            return AppleSignInUseCase(repository: repository)
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
            let repository = r.resolve(UserProfileRepository.self)!
            return DefaultUserProfileUseCase(repository: repository)
        }
        
        // Register Repositories
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
        
        container.register(ImageRepository.self) { r in
            let imgRemoteDataSource = r.resolve(ImageRemoteDataSource.self)!
            return DefaultStorageImageRepositoryImpl(imageRemoteDataSource: imgRemoteDataSource)
        }
        
        container.register(UserProfileRepository.self) { r in
            let userProfileDataSource = r.resolve(UserProfileRemoteDataSource.self)!
            return DefaultUserProfileRepositoryImpl(userProfileDataSource: userProfileDataSource)
        }
        
        // Register Data Sources
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
