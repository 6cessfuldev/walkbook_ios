//
//  SubscribeViewController.swift
//  walkbook
//
//  Created by 육성민 on 8/27/24.
//

import UIKit

class SubscribeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView()
    
    private let cardData: [(title: String, imageName: String)] = [
        (title: "Card 1", imageName: "sample1"),
        (title: "Card 2", imageName: "sample1"),
        (title: "Card 3", imageName: "sample1")
    ]
    
    let card: CardView = {
        let card = CardView()
        card.configure(image: UIImage(named: "sample1")!, title: "컨텐츠 제목")
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        
        configureCustomNavigationBar()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CardCell.self, forCellReuseIdentifier: CardCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .background
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardCell.identifier, for: indexPath) as? CardCell else {
            return UITableViewCell()
        }
        let data = cardData[indexPath.row]
        cell.configure(image: UIImage(named: data.imageName), title: data.title)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

}
