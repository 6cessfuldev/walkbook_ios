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
    private let container: Container
    
    init(
        navigationController: UINavigationController,
        container: Container
    ) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let vc = container.resolve(ViewController.self)!
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
