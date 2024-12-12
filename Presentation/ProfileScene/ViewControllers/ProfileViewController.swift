import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {
    
    private let viewModel: UserProfileViewModel
    
    weak var coordinator: ProfileFlowCoordinator!
    let disposeBag = DisposeBag()
    
    let profileView = ProfileCardView()
    
    private let sectionTitleLabel: UILabel = {
       let label = UILabel()
        label.text = "기록"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 200, height: 200)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let data = [
        (UIImage(named: "sample1"), "Title 1", "Author 1"),
        (UIImage(named: "sample2"), "Title 2", "Author 2"),
        (UIImage(named: "sample3"), "Title 3", "Author 3"),
        (UIImage(named: "sample1"), "Title 4", "Author 4")
    ]
    
    init(viewModel: UserProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        configureCustomNavigationBar()
        
        view.addSubview(sectionTitleLabel)
        
        setupProfileView()
        setupCollectionView()
        
        bindCollectionView()
        
    }
    
    private func setupProfileView() {
        profileView.configure(image: UIImage(named: "sample1"), name: "유저 이름")
        view.addSubview(profileView)
        profileView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 10),
            profileView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 16),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sectionTitleLabel.heightAnchor.constraint(equalToConstant: 20),
            collectionView.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ThumbnailCardCell.self, forCellWithReuseIdentifier: ThumbnailCardCell.identifier)
    }
    
    private func bindCollectionView() {
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let selectedItem = self.data[indexPath.row]
                print("Selected item: \(selectedItem.1)") // Debug log
                
                self.coordinator.showContentMain()
            })
            .disposed(by: self.disposeBag)
        
        viewModel.currentUser
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] userProfile in
                guard let self = self else { return }
                self.profileView.configure(
                    image: userProfile?.imageUrl != nil ? UIImage(named: userProfile!.imageUrl!) : UIImage(systemName: "person.crop.circle.fill"),
                    name: userProfile?.name ?? "Unknown User"
                )
            })
            .disposed(by: disposeBag)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCardCell.identifier, for: indexPath) as! ThumbnailCardCell
        let (thumbnail, title, author) = data[indexPath.item]
        cell.configure(thumbnail: thumbnail, title: title, author: author)
        return cell
    }
}
