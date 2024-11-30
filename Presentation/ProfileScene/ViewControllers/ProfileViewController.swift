import UIKit

class ProfileViewController: UIViewController {
    
    let profileView = ProfileCardView()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        configureCustomNavigationBar()
        
        setupProfileView()
        setupCollectionView()
        
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
            collectionView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ThumbnailCardCell.self, forCellWithReuseIdentifier: ThumbnailCardCell.identifier)
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
