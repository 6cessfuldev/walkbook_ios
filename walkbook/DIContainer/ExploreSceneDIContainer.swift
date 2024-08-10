//
//  ExploreSceneDIContainer.swift
//  walkbook
//
//  Created by 육성민 on 8/7/24.
//

import Foundation

class ExploreSceneDIContainer: ExploreFlowCoordinatorDependencies {
    struct Dependencies {
        let authenticationViewModel: AuthenticationViewModel
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeExploreViewController() -> ExploreViewController {
        ExploreViewController(viewModel: dependencies.authenticationViewModel)
    }
}
