//
//  GoogleSignInButton.swift
//  walkbook
//
//  Created by 육성민 on 7/14/24.
//

import UIKit

class GoogleSignInButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        var configuration = UIButton.Configuration.filled()
        
        configuration.baseBackgroundColor = UIColor.white
        configuration.cornerStyle = .medium
        
        // Image
        let imageSize = CGSize(width: 16, height: 16)
        let resizedImage = UIImage(named: "google_logo")?.resize(targetSize: imageSize)
        setImage(resizedImage, for: .normal)
        configuration.imagePadding = 14
        
        // Title
        var attributedTitle = AttributedString("Google로 계속하기")
//        attributedTitle.font = UIFont(name: "Roboto-Medium", size: 16)
        attributedTitle.foregroundColor = UIColor.black
        configuration.titlePadding = 14
        
        configuration.attributedTitle = attributedTitle
        self.configuration = configuration
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
