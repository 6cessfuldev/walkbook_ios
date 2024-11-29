import UIKit

class ProfileViewController: UIViewController {
    
    let profileView = ProfileCardView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        configureCustomNavigationBar()
        
        setupProfileView()
        
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

}
