import UIKit

extension UIViewController {
    func configureCustomNavigationBar() {
        let titleView = UIView()
        
        let iconImageView = UIImageView(image: UIImage(named: "AppIcon_nobg"))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Walkbook"
        
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
        
        guard let customFont = UIFont(name: "YeonSung-Regular", size: 24) else { return }
        
        titleLabel.font = customFont
        titleLabel.textColor = UIColor.white
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: titleView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor)
        ])
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        self.navigationItem.titleView = titleView
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleView)

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .background // 공통 색상 설정
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}
