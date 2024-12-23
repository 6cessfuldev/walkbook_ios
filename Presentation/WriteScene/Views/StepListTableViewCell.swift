import UIKit
import CoreLocation

class StepListTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(iconImageView)
        containerStackView.addArrangedSubview(textStackView)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure Cell
    
    func configure(with step: Step) {
        switch step.type {
        case .text(let content):
            iconImageView.image = UIImage(systemName: "text.alignleft")
            titleLabel.text = "텍스트 타입"
            subtitleLabel.text = content
            
        case .music(let url):
            iconImageView.image = UIImage(systemName: "music.note")
            titleLabel.text = "오디오 타입"
            subtitleLabel.text = url
            
        case .video(let url):
            iconImageView.image = UIImage(systemName: "video")
            titleLabel.text = "비디오 타입"
            subtitleLabel.text = url
            
        case .image(let url):
            iconImageView.image = UIImage(systemName: "photo")
            titleLabel.text = "이미지 타입"
            subtitleLabel.text = url
            
        case .question(let correctAnswer, _):
            iconImageView.image = UIImage(systemName: "questionmark.circle")
            titleLabel.text = "퀴즈 타입"
            subtitleLabel.text = "정답: \(correctAnswer)"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
}
