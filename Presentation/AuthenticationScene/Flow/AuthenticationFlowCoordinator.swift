//
//  AuthenticationFlowCoordinator.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//
protocol AuthenticationFlowCoordinatorDependencies {
    func makeAuthenticationViewController() -> AuthenticationViewController
}

import UIKit
class AuthenticationFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let dependencies: AuthenticationFlowCoordinatorDependencies

    init(navigationController: UINavigationController,
         dependencies: AuthenticationFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let vc = dependencies.makeAuthenticationViewController()
        navigationController.pushViewController(vc, animated: false)
    }
}
