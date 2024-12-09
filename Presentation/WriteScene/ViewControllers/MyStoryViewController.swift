import UIKit
import RxSwift
import RxCocoa

class MyStoryViewController: UIViewController {
    
    weak var coordinator: MainFlowCoordinator!
    
    private let viewModel: MyStoryViewModel
    let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    
    init(viewModel: MyStoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindCollectionView()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
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
        
        viewModel.storyData
            .bind(to: tableView.rx.items(cellIdentifier: CardCell.identifier, cellType: CardCell.self)) { _, item, cell in
                
                cell.configure(image: UIImage(named: item.imageUrl), title: item.title)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            tableView.rx.itemSelected,
            viewModel.storyData
        )
        .subscribe(onNext: { [weak self] indexPath, stories in
            guard let self = self else { return }
            let storyCount = stories.count
            print("Number of stories: \(storyCount)")
            
            self.coordinator.showContentMain()
        })
        .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }

}

extension MyStoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
