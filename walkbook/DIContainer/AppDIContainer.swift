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
        
        // Register ViewModel
        container.register(AuthenticationViewModel.self) { r in
            let googleSignInUseCase = r.resolve(GoogleSignInUseCaseProtocol.self)!
            let kakaoSignInUsecase = r.resolve(KakaoSignInUseCaseProtocol.self)!
            let naverSignInUsecase = r.resolve(NaverSignInUseCaseProtocol.self)!
            let appleSignInUseCase = r.resolve(AppleSignInUseCaseProtocol.self)!
            return AuthenticationViewModel(
                googleSignInUseCase: googleSignInUseCase,
                kakaoSignInUseCase: kakaoSignInUsecase,
                naverSignInUseCase: naverSignInUsecase,
                appleSignInUseCase: appleSignInUseCase
            )
        }.inObjectScope(.container)
        
        // Register ViewControllers
        container.register(AuthenticationViewController.self) { r in
            let viewModel = r.resolve(AuthenticationViewModel.self)!
            return AuthenticationViewController(viewModel: viewModel)
        }
        
        container.register(MainViewController.self) { r in
            let viewModel = r.resolve(AuthenticationViewModel.self)!
            return MainViewController(viewModel: viewModel)
        }
        
        
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
        
        // Register Repositories
        container.register(AuthenticationRepository.self) { r in
            let googleDataSource = r.resolve(GoogleSignRemoteDataSource.self)!
            let kakaoDataSource = r.resolve(KakaoSignRemoteDataSource.self)!
            let naverDataSource = r.resolve(NaverSignRemoteDataSource.self)!
            let appleDataSource = r.resolve(AppleSignRemoteDataSource.self)!
            let firebaseAuthDataSource = r.resolve(FirebaseAuthRemoteDataSource.self)!
            
            return FirebaseAuthenticationRepositoryImpl(
                googleSignRemoteDataSource: googleDataSource,
                kakaoSignRemoteDataSource: kakaoDataSource,
                naverSignRemoteDataSource: naverDataSource,
                appleSignRemoteDataSource: appleDataSource,
                firebaseAuthRemoteDataSource: firebaseAuthDataSource
            )
        }
        
        // Register Data Sources
        container.register(AppleSignRemoteDataSource.self) { _ in AppleSignRemoteDataSourceImpl() }
        container.register(GoogleSignRemoteDataSource.self) { _ in GoogleSignRemoteDataSourceImpl() }
        container.register(KakaoSignRemoteDataSource.self) { _ in KakaoSignRemoteDataSourceImpl() }
        container.register(NaverSignRemoteDataSource.self) { _ in NaverSignRemoteDataSourceImpl() }
        container.register(FirebaseAuthRemoteDataSource.self) { _ in FirebaseAuthRemoteDataSourceImpl() }
    }
    
    // MARK: - DIContainers of scenes
    
    func makeExploreSceneDIContainer() -> ExploreSceneDIContainer {
        let authenticationViewModel = container.resolve(AuthenticationViewModel.self)!
        let dependencies = ExploreSceneDIContainer.Dependencies(
            authenticationViewModel: authenticationViewModel)
        return ExploreSceneDIContainer(dependencies: dependencies)
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
}

//MARK: - ExploreFlowCoordinator

extension AppDIContainer: MainFlowCoordinatorDependencies {
    func makeExploreViewController() -> ExploreViewController {
        let authenticationViewModel = container.resolve(AuthenticationViewModel.self)!
        let vc = ExploreViewController(viewModel: authenticationViewModel)
        return vc
    }
    
    func makeMainViewController() -> MainViewController {
        container.resolve(MainViewController.self)!
    }
    
    func makeExploreFlowCoordinator(navigationController: UINavigationController) -> ExploreFlowCoordinator {
        return ExploreFlowCoordinator(navigationController: navigationController, dependencies: self.makeExploreSceneDIContainer())
    }
}
