//
//  SignUpView.swift
//  walkbook
//
//  Created by 육성민 on 7/14/24.
//

import UIKit

class SignUpView: UIView {

    let googleSignUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up with Google", for: .normal)
        button.setImage(UIImage(named: "google_logo"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "googleSignUpButton"
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
        addSubview(googleSignUpButton)
        
        NSLayoutConstraint.activate([
            googleSignUpButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 100),
            googleSignUpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -100),
            googleSignUpButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            googleSignUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
