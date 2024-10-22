import UIKit
import RxSwift

class ExploreViewController: UIViewController {
    
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
}
