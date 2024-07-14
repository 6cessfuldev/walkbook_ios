//
//  LoginViewController.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    private let chooseLoginView: ChooseLoginView = {
        let view = ChooseLoginView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "chooseLoginView"
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "authenticationVC"
        setBackground()
        setupUI()
    }
    
    private func setBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "login_background")
        backgroundImage.contentMode = .scaleAspectFill
        
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    private func setupUI() {
        view.addSubview(chooseLoginView)
        
        NSLayoutConstraint.activate([
            chooseLoginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chooseLoginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chooseLoginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chooseLoginView.topAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
