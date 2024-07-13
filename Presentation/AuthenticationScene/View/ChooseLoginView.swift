//
//  ChooseLoginView.swift
//  walkbook
//
//  Created by 육성민 on 7/14/24.
//

import UIKit

class ChooseLoginView: UIView {
    
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인 하시겠습니까?", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .buttonPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "signInButton"
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("신규 가입하시겠습니까?", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .background
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "signUpButton"
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(signInButton)
        addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            signInButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            signInButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            signInButton.topAnchor.constraint(equalTo: topAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 60),

            signUpButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            signUpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            signUpButton.topAnchor.constraint(equalTo: topAnchor, constant: 120),
            signUpButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupActions() {
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    @objc private func signInButtonTapped() {
        self.isHidden = true
    }
    
    @objc private func signUpButtonTapped() {
        self.isHidden = true
    }
}
