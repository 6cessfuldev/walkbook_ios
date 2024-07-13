//
//  LoginViewController.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//

import UIKit

class AuthenticationViewController: UIViewController {

    private let testLabel: UILabel = {
        let label = UILabel()
        label.text = "AuthenticationVC"
        label.textColor = .black
        
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
