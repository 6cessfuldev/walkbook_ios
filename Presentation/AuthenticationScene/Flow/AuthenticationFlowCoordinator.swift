//
//  AuthenticationFlowCoordinator.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//
protocol AuthenticationFlowCoordinatorDependencies {
    func makeAuthenticationViewController() -> AuthenticationViewController
}

protocol AuthenticationFlowCoordinatorDelegate {
    func didFinishAuthentication(coordinator: AuthenticationFlowCoordinator)
}

import UIKit
class AuthenticationFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: AuthenticationFlowCoordinatorDelegate!
    private let dependencies: AuthenticationFlowCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: AuthenticationFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let vc = dependencies.makeAuthenticationViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func didFinishAuthentication() {
        delegate.didFinishAuthentication(coordinator: self)
    }
}
