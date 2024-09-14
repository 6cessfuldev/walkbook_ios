//
//  ProfileViewController.swift
//  walkbook
//
//  Created by 육성민 on 8/27/24.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let pageLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile Page"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(pageLabel)
        
        NSLayoutConstraint.activate([
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

}
