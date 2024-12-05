import UIKit
import RxSwift
import RxCocoa

class WriteBottomMenuViewController: UIViewController {
    
    weak var coordinator: MainFlowCoordinator!
    private let disposeBag = DisposeBag()
    
    let writeNewBtn: UIButton = {
        let button = UIButton()
        button.setTitle("새로\n만들기", for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .accent
        button.setTitleColor(.white,for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let continueBtn: UIButton = {
        let button = UIButton()
        button.setTitle("내가 쓴\n이야기", for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .accent
        button.setTitleColor(.white,for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        view.addSubview(writeNewBtn)
        view.addSubview(continueBtn)
        
        NSLayoutConstraint.activate([
            // Position writeNewBtn
            writeNewBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            writeNewBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            writeNewBtn.widthAnchor.constraint(equalToConstant: 80),
            writeNewBtn.heightAnchor.constraint(equalToConstant: 80),
            
            // Position continueBtn below writeNewBtn
            continueBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            continueBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            continueBtn.widthAnchor.constraint(equalToConstant: 80),
            continueBtn.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        writeNewBtn.rx.tap
            .bind { [weak self] in
                self?.coordinator.dismissBottomModal()
                self?.coordinator.showWriteNewStoryVC()
                
            }
            .disposed(by: disposeBag)
    }
}
