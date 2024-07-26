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
            let appleSignInuseCase = r.resolve(AppleSignInUseCase.self)!
            return AuthenticationViewModel(appleSignInUseCase: appleSignInuseCase)
        }
        
        // Register ViewControllers
        container.register(AuthenticationViewController.self) { r in
            let viewModel = r.resolve(AuthenticationViewModel.self)!
            return AuthenticationViewController(viewModel: viewModel)
        }
        
        // Register UseCases
        container.register(AppleSignInUseCase.self) { r in
            let repository = r.resolve(AuthenticationRepository.self)!
            return DefaultAppleSignInUseCase(repository: repository)
        }
        
        // Register Repositories
        container.register(AuthenticationRepository.self) { _ in
            return FirebaseAuthenticationRepository()
        }
    }
}

//MARK: - AuthenticationFlowCoordinator

extension AppDIContainer: AuthenticationFlowCoordinatorDependencies {
    func makeAuthenticationFlowCoordinator(navigationController: UINavigationController) -> AuthenticationFlowCoordinator {
        AuthenticationFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
    
    func makeAuthenticationViewController() -> AuthenticationViewController {
        container.resolve(AuthenticationViewController.self)!
    }
}
