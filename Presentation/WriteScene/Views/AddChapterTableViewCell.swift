import UIKit

class AddChapterTableViewCell: UITableViewCell {
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음 챕터 추가하기 +", for: .normal)
        button.setTitleColor(.yellow, for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(addButton)
        contentView.backgroundColor = .accent
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
}
