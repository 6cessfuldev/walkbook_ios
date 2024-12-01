//
//  SubscribeViewController.swift
//  walkbook
//
//  Created by 육성민 on 8/27/24.
//

import UIKit
import RxSwift
import RxCocoa

class SubscribeViewController: UIViewController {
    
    weak var coordinator: SubscribeFlowCoordinator!
    let disposeBag = DisposeBag()
    
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
        
        setupTableView()
        bindCollectionView()
    }
    
    func setupTableView() {
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
    
    private func bindCollectionView() {
        
        Observable.just(cardData)
            .bind(to: tableView.rx.items(cellIdentifier: CardCell.identifier, cellType: CardCell.self)) { _, item, cell in
                
                cell.configure(image: UIImage(named: item.imageName), title: item.title)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let selectedItem = self.cardData[indexPath.row]
                print("Selected item: \(selectedItem.1)") // Debug log
                
                self.coordinator.showContentMain()
            })
            .disposed(by: self.disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

}

extension SubscribeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 
    }
}
