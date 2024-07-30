//
//  AppFlowCoordinator.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//

import UIKit
import Swinject

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set}
    var navigationController: UINavigationController { get set }
    
    func start ()
}

final class AppFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(
        navigationController: UINavigationController,
        appDIContainer: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    func start() {
        let authCoordinator = appDIContainer.makeAuthenticationFlowCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    func didFinishAuthentication() {
        let mainCoordinator = appDIContainer.makeMainFlowCoordinator(navigationController: navigationController)
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
    
    private func childDidFinish(_ coordinator: Coordinator?) {
        for (index, childCoordinator) in childCoordinators.enumerated() {
            if childCoordinator === coordinator {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

extension AppFlowCoordinator: AuthenticationFlowCoordinatorDelegate {
    func didFinishAuthentication(coordinator: AuthenticationFlowCoordinator) {
        childDidFinish(coordinator)
        let mainCoordinator = appDIContainer.makeMainFlowCoordinator(navigationController: navigationController)
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
}
