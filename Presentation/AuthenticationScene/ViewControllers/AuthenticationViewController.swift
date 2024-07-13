//
//  LoginViewController.swift
//  walkbook
//
//  Created by 육성민 on 7/13/24.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
    }
    
    private func setBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "login_background")
        backgroundImage.contentMode = .scaleAspectFill
        
        self.view.insertSubview(backgroundImage, at: 0)
    }
}
