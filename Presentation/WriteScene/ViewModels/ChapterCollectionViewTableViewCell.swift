import UIKit
import RxSwift

class ChapterCollectionViewTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var chapters: [Chapter] = []
    private var currentIndex: Int = 0
    
    let displayedChapter = PublishSubject<Int>()
    var disposeBag = DisposeBag()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("◀", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("▶", for: .normal)
        button.setTitleColor(.blue, for: .normal)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    
    private func setupUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ChapterCell")
        
        contentView.addSubview(collectionView)
        contentView.addSubview(leftButton)
        contentView.addSubview(rightButton)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60),
            
            leftButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            leftButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            rightButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            rightButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        leftButton.addTarget(self, action: #selector(showPreviousItem), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(showNextItem), for: .touchUpInside)
    }
    
    func configure(with chapters: [Chapter], currentIndex: Int = 0) {
        self.chapters = chapters
        self.currentIndex = currentIndex
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        updateButtonVisibility()
    }
    
    private func updateButtonVisibility() {
        leftButton.isHidden = (currentIndex == 0)
        rightButton.isHidden = (currentIndex == chapters.count - 1)
    }
    
    @objc private func showPreviousItem() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        updateButtonVisibility()
        emitDisplayedChapter()
    }
    
    @objc private func showNextItem() {
        guard currentIndex < chapters.count - 1 else { return }
        currentIndex += 1
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        updateButtonVisibility()
        emitDisplayedChapter()
    }
    
    private func emitDisplayedChapter() {
        displayedChapter.onNext(currentIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChapterCell", for: indexPath)
        cell.backgroundColor = .lightGray
        
        let chapter = chapters[indexPath.item]
        
        let label = UILabel()
        label.text = chapter.title
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 셀이 CollectionView 크기와 동일하게 설정
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
