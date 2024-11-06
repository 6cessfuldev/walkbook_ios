import UIKit
import RxSwift

class ExploreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate var viewModel: AuthenticationViewModel!
    weak var coordinator: ExploreFlowCoordinator!
    let disposeBag = DisposeBag()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let contentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("content", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var collectionView: UICollectionView!
    let images: [UIImage] = [
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!,
        UIImage(named: "sample1")!
    ]
    
    init(viewModel: AuthenticationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("MainViewController deinitialized: \(self)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        view.addSubview(idLabel)
        view.addSubview(contentButton)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            idLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            idLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentButton.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: contentButton.bottomAnchor, constant: 20)
        ])
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .background

            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        // 아이콘 이미지와 앱 이름이 있는 UIView 생성
        let titleView = UIView()

        // 아이콘 이미지 설정
        let iconImageView = UIImageView(image: UIImage(named: "AppIcon_nobg")) // 앱 아이콘 이미지 설정
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true


        // 앱 이름 설정
        let titleLabel = UILabel()
        titleLabel.text = "Walkbook" // 앱 이름
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold) // 원하는 폰트 설정
        titleLabel.textColor = UIColor.white // 원하는 색상 설정

        // StackView로 아이콘과 앱 이름을 함께 배치
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading

        // StackView의 크기 설정
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(stackView)

        // StackView에 제약 조건 추가 (왼쪽 정렬)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: titleView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])

        // titleView 크기 설정
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40) // 원하는 크기 설정

        // 타이틀을 titleView로 설정
        self.navigationItem.titleView = titleView

        // 왼쪽 정렬을 위해 왼쪽에 padding 추가
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleView)
        
        setupCollectionView()
        
        viewModel.userEmail
            .asObservable()
            .map { $0 ?? "No email" }
            .bind(to: idLabel.rx.text)
            .disposed(by: disposeBag)
        
        contentButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator.showContentInfo()
            })
            .disposed(by: disposeBag)
        
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.userEmail.accept(nil)
                self?.coordinator.didLogout()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 컬렉션 뷰 레이아웃 가져오기
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        // 아이템의 너비와 간격 계산
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        // 컬렉션 뷰 너비의 절반에서 아이템 너비의 절반을 뺀 만큼을 여백으로 설정
        let insetX = (collectionView.bounds.width / 2) - (cellWidthIncludingSpacing / 2)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        collectionView.contentOffset = CGPoint(x: -insetX, y: 0) // 시작 위치를 첫 번째 아이템으로 맞추기
        
        // 셀의 높이와 컬렉션 뷰의 높이를 기준으로 중앙 정렬을 위한 여백 계산
        let insetY = max((collectionView.bounds.height - layout.itemSize.height) / 2, 0)
        
        // 상하 여백을 설정하여 아이템들이 수직 중앙에 오도록 설정
        layout.sectionInset = UIEdgeInsets(top: insetY, left: layout.sectionInset.left, bottom: insetY, right: layout.sectionInset.right)
    }
    
    func setupCollectionView() {
        let layout = CarouselFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 300),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
        ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath) as! CarouselCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
}
