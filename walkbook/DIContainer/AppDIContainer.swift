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
            return AuthenticationViewController()
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
