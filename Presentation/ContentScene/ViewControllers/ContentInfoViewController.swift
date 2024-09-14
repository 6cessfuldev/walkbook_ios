//
//  ContentInfoViewController.swift
//  walkbook
//
//  Created by 육성민 on 8/28/24.
//

import UIKit
import RxSwift

class ContentInfoViewController: UIViewController {
    
    weak var coordinator: ExploreFlowCoordinator!
    let disposeBag = DisposeBag()
    
    let pageLabel: UILabel = {
        let label = UILabel()
        label.text = "Content Info Page"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("content", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        view.addSubview(pageLabel)
        view.addSubview(contentButton)
        
        NSLayoutConstraint.activate([
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentButton.topAnchor.constraint(equalTo: pageLabel.bottomAnchor, constant: 20),
        ])
        
        contentButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator.showContentMain()
            })
            .disposed(by: disposeBag)
    }

}
