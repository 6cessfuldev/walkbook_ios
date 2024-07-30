//
//  KakaoSignInButton.swift
//  walkbook
//
//  Created by 육성민 on 7/15/24.
//

import UIKit

class KakaoSignInButton: UIButton {
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
        
        configuration.baseBackgroundColor = UIColor(hex:"#FEE500")
        configuration.cornerStyle = .medium
        
        // Image
        let imageSize = CGSize(width: 16, height: 16)
        let resizedImage = UIImage(named: "kakao_logo")?.resize(targetSize: imageSize)
        setImage(resizedImage, for: .normal)
        configuration.imagePadding = 12
        
        // Title
        var attributedTitle = AttributedString("카카오로 계속하기")
        attributedTitle.foregroundColor = UIColor.black
        configuration.titlePadding = 12
        
        configuration.attributedTitle = attributedTitle
        self.configuration = configuration
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
