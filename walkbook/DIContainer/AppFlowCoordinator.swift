//
//  AppFlowCoordinator.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//

import UIKit
import Swinject

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set}
    var navigationController: UINavigationController { get set }
    
    func start ()
}

final class AppFlowCoordinator: Coordinator{
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
        let flow = appDIContainer.makeAuthenticationFlowCoordinator(navigationController: navigationController)
        flow.start()
    }
}
