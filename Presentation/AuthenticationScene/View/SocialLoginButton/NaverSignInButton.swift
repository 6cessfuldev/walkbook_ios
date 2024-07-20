//
//  NaverSignInButton.swift
//  walkbook
//
//  Created by 육성민 on 7/20/24.
//

import UIKit

class NaverSignInButton: UIButton {
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
        
        configuration.baseBackgroundColor = UIColor(hex:"#03C75A")
        configuration.cornerStyle = .medium
        
        // Image
        let imageSize = CGSize(width: 30, height: 30)
        let resizedImage = UIImage(named: "naver_logo")?.resize(targetSize: imageSize)
        setImage(resizedImage, for: .normal)
        configuration.imagePadding = 7
        
        // Title
        var attributedTitle = AttributedString("네이버로 계속하기")
        attributedTitle.foregroundColor = UIColor.white
        configuration.titlePadding = 7
        
        configuration.attributedTitle = attributedTitle
        self.configuration = configuration
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
