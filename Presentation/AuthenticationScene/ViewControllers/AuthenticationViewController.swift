//
//  LoginViewController.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//

import UIKit

enum AuthenticationState {
    case chooseLogin
    case signIn
    case signUp
}

class AuthenticationViewController: UIViewController {
    
    private let chooseLoginView: ChooseLoginView = {
        let view = ChooseLoginView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "chooseLoginView"
        return view
    }()
    
    private let signInView: SignInView = {
        let view = SignInView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "signInView"
        view.isHidden = true
        return view
    }()
    
    private let signUpView: SignUpView = {
        let view = SignUpView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "signUpView"
        view.isHidden = true
        return view
    }()
    
    private var currentState: AuthenticationState = .chooseLogin {
        didSet {
            updateViewState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "authenticationVC"
        setBackground()
        setupUI()
        setupActions()
    }
    
    private func setBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "login_background")
        backgroundImage.contentMode = .scaleAspectFill
        
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    private func setupUI() {
        view.addSubview(chooseLoginView)
        view.addSubview(signInView)
        view.addSubview(signUpView)
        
        NSLayoutConstraint.activate([
            chooseLoginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chooseLoginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chooseLoginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            chooseLoginView.topAnchor.constraint(equalTo: view.centerYAnchor),
            
            signInView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signInView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            signInView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            signInView.topAnchor.constraint(equalTo: view.centerYAnchor),
            
            signUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            signUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            signUpView.topAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupActions() {
        chooseLoginView.signInButton.addTarget(self, action: #selector(showSignInView), for: .touchUpInside)
        chooseLoginView.signUpButton.addTarget(self, action: #selector(showSignUpView), for: .touchUpInside)
    }

    @objc private func showSignInView() {
        currentState = .signIn
    }

    @objc private func showSignUpView() {
        currentState = .signUp
    }
    
    private func updateViewState() {
        chooseLoginView.isHidden = true
        signInView.isHidden = true
        signUpView.isHidden = true
        
        switch currentState {
        case .chooseLogin:
            chooseLoginView.isHidden = false
        case .signIn:
            signInView.isHidden = false
        case .signUp:
            signUpView.isHidden = false
        }
    }
}

//extension ChooseLoginViewDelegate {
//    func
//}
