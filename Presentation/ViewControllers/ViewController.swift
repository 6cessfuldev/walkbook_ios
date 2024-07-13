//
//  ViewController.swift
//  walkbook
//
//  Created by 육성민 on 7/10/24.
//

import UIKit

class ViewController: UIViewController {
    weak var coordinator: AppFlowCoordinator?
    
    private let testLabel: UILabel = {
        let label = UILabel()
        label.text = "초기세팅 테스트"
        label.textColor = .black
        label.font = .systemFont(ofSize: 15)
        label.clipsToBounds = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(testLabel)
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -50)
        ])
        view.backgroundColor = .white
    }

}

