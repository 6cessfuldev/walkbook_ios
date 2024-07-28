//
//  LoginViewController.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//

import UIKit
import RxSwift
import RxCocoa

class AuthenticationViewController: UIViewController {
    fileprivate var viewModel: AuthenticationViewModel!
    private let disposeBag = DisposeBag()
    
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
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "authenticationVC"
        setBackground()
        setupUI()
        setupBindings()
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
    
    private func setupBindings() {
        chooseLoginView.signInButton.rx.tap
            .bind(to: viewModel.signInTapped)
            .disposed(by: disposeBag)
        
        chooseLoginView.signUpButton.rx.tap
            .bind(to: viewModel.signUpTapped)
            .disposed(by: disposeBag)
        
        signInView.googleSignInButton.rx.tap
            .map { [weak self] in
                self
            }
            .compactMap { $0 }
            .bind(to: viewModel.googleSignInTapped)
            .disposed(by: disposeBag)
        
        signInView.kakaoSignInButton.rx.tap
            .bind(to: viewModel.kakaoSignInTapped)
            .disposed(by: disposeBag)
        
        signInView.naverSignInButton.rx.tap
            .bind(to: viewModel.naverSignInTapped)
            .disposed(by: disposeBag)
        
        signInView.appleSignInButton.rx.tap
            .bind(to: viewModel.appleSignInTapped)
            .disposed(by: disposeBag)
        
        viewModel.currentState
            .subscribe(onNext: { [weak self] state in
                self?.updateViewState(state)
            })
            .disposed(by: disposeBag)
        
        viewModel.userEmail
            .subscribe(onNext: { email in
                if let email = email {
                    // Handle successful sign-in
                    print("User Email: \(String(describing: email))")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { error in
                if let error = error {
                    // Handle error
                    print("Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateViewState(_ state: AuthenticationState) {
        chooseLoginView.isHidden = true
        signInView.isHidden = true
        signUpView.isHidden = true
        
        switch state {
        case .chooseLogin:
            chooseLoginView.isHidden = false
        case .signIn:
            signInView.isHidden = false
        case .signUp:
            signUpView.isHidden = false
        }
    }
}
