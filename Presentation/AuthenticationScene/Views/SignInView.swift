//
//  SignInView.swift
//  walkbook
//
//  Created by 육성민 on 7/14/24.
//

import UIKit

class SignInView: UIView {

    let googleSignInButton: UIButton = {
        let button = GoogleSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "googleSignInButton"
        return button
    }()
    
    let kakaoSignInButton: UIButton = {
        let button = KakaoSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "kakaoSignInButton"
        return button
    }()
    
    let naverSignInButton: UIButton = {
        let button = NaverSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "naverSignInButton"
        return button
    }()
    
    let appleSignInButton: UIButton = {
        let button = AppleSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "appleSignInButton"
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(googleSignInButton)
        addSubview(kakaoSignInButton)
        addSubview(naverSignInButton)
        addSubview(appleSignInButton)
        
        NSLayoutConstraint.activate([
            googleSignInButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            googleSignInButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            googleSignInButton.topAnchor.constraint(equalTo: topAnchor),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            kakaoSignInButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            kakaoSignInButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            kakaoSignInButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 30),
            kakaoSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            naverSignInButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            naverSignInButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            naverSignInButton.topAnchor.constraint(equalTo: kakaoSignInButton.bottomAnchor, constant: 30),
            naverSignInButton.heightAnchor.constraint(equalToConstant: 50),
            
            appleSignInButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            appleSignInButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            appleSignInButton.topAnchor.constraint(equalTo: naverSignInButton.bottomAnchor, constant: 30),
            appleSignInButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
