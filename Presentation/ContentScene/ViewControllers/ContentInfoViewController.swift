//
//  ContentInfoViewController.swift
//  walkbook
//
//  Created by 육성민 on 8/28/24.
//

import UIKit
import RxSwift

class ContentInfoViewController: UIViewController {
    
    weak var coordinator: ContentConsumableCoordinator!
    let disposeBag = DisposeBag()
    
    let contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("content", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let contentView: ContentInfoView = {
        let view = ContentInfoView()
        view.configure(
            image: UIImage(named: "sample1"),
            title: "Sample Title",
            author: "Author Name",
            description: "This is a detailed description of the content. It can span multiple lines."
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        
        view.addSubview(contentButton)
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentButton.topAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        contentButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator.showContentMain()
            })
            .disposed(by: disposeBag)
    }

}
