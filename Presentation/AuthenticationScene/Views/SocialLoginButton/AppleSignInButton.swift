//
//  AppleSignInButton.swift
//  walkbook
//
//  Created by 육성민 on 7/20/24.
//

import UIKit

class AppleSignInButton: UIButton {
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
        
        configuration.baseBackgroundColor = UIColor.black
        configuration.cornerStyle = .medium
        
        // Image
        let imageSize = CGSize(width: 32, height: 32)
        let resizedImage = UIImage(named: "apple_logo")?.resize(targetSize: imageSize)
        setImage(resizedImage, for: .normal)
        configuration.imagePadding = 5
        
        // Title
        var attributedTitle = AttributedString("Apple로 게속하기")
        attributedTitle.foregroundColor = UIColor.white
        configuration.titlePadding = 5
        
        configuration.attributedTitle = attributedTitle
        self.configuration = configuration
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
