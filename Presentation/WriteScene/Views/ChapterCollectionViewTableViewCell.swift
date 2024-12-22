import UIKit
import RxSwift

class ChapterCollectionViewTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var chapters: [NestedChapter] = []
    private var currentIndex: Int = 0
    private var level: Int = 0
    
    let displayedChapter = PublishSubject<Int>()
    let addButtonAction = PublishSubject<Void>()
    let selectButtonAction = PublishSubject<Void>()
    var disposeBag = DisposeBag()
    
    private var addButtonWidthConstraint: NSLayoutConstraint?
    private var collectionViewTrailingConstraint: NSLayoutConstraint?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("◀", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("▶", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.yellow, for: .normal)
        button.backgroundColor = .buttonPrimary
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag() // 기존 바인딩 해제
            // 바인딩 재설정 필요
        setupBindings()
    }

    
    private func setupUI() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ChapterCell")
        
        contentView.backgroundColor = .background
        
        contentView.addSubview(collectionView)
        contentView.addSubview(leftButton)
        contentView.addSubview(rightButton)
        contentView.addSubview(addButton)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButtonWidthConstraint = addButton.widthAnchor.constraint(equalToConstant: addButton.isHidden ? 0 : 40)
        collectionViewTrailingConstraint = collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: addButton.isHidden ? 0 : -40)

        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            collectionViewTrailingConstraint!,
            
            leftButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            leftButton.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 16),
            leftButton.widthAnchor.constraint(equalToConstant: 30),
            leftButton.heightAnchor.constraint(equalToConstant: 30),

            rightButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            rightButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -16),
            rightButton.widthAnchor.constraint(equalToConstant: 30),
            rightButton.heightAnchor.constraint(equalToConstant: 30),
    
            addButton.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            addButtonWidthConstraint!
        ])
        
        
    }
    
    func configure(with chapters: [NestedChapter], currentIndex: Int = 0, level: Int) {
        self.chapters = chapters
        self.currentIndex = currentIndex
        self.level = level
        
        updateAddButtonVisibility(isHidden: level == 0)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
        updateButtonVisibility()
    }
    
    private func setupBindings() {
        leftButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showPreviousItem()
            })
            .disposed(by: disposeBag)
        rightButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showNextItem()
            })
            .disposed(by: disposeBag)
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.addOtherChapter()
            })
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false // 버튼 등의 터치를 방해하지 않도록 설정
        collectionView.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .filter { [weak self] gesture in
                guard let self = self else { return false }
                let location = gesture.location(in: self.collectionView)
                let touchedView = self.collectionView.hitTest(location, with: nil)
                
                // 버튼 같은 상호작용 가능한 뷰를 필터링
                return !(touchedView is UIControl)
            }
            .bind { [weak self] _ in
                self?.selectAction()
            }
            .disposed(by: disposeBag)
        
    }
    
    private func updateButtonVisibility() {
        leftButton.isHidden = (currentIndex == 0)
        rightButton.isHidden = (currentIndex == chapters.count - 1)
    }
    
    private func updateAddButtonVisibility(isHidden: Bool) {
        addButton.isHidden = isHidden

        addButtonWidthConstraint?.constant = isHidden ? 0 : 40
        collectionViewTrailingConstraint?.constant = isHidden ? 0 : -40

        self.contentView.layoutIfNeeded()
    }
    
    private func showPreviousItem() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        updateButtonVisibility()
        emitDisplayedChapter()
    }
    
    private func showNextItem() {
        guard currentIndex < chapters.count - 1 else { return }
        currentIndex += 1
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        updateButtonVisibility()
        emitDisplayedChapter()
    }
    
    private func addOtherChapter() {
        addButtonAction.onNext(())
    }
    
    private func selectAction() {
        selectButtonAction.onNext(())
    }
    
    private func emitDisplayedChapter() {
        displayedChapter.onNext(currentIndex)
            
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChapterCell", for: indexPath)
        cell.backgroundColor = .white
        
        // 배열 범위를 초과하지 않도록 확인
        guard indexPath.item < chapters.count else {
            print("Error: Index \(indexPath.item) is out of range for chapters array of size \(chapters.count)")
            print("chapters.count : \(chapters.count) indexPath : \(indexPath.item) ")
            return cell
        }
        
        let chapter = chapters[indexPath.item]
        print("Configuring cell for chapter: \(chapter.title) at index \(indexPath.item)")
        
        let label = UILabel()
        label.text = chapter.title.isEmpty ? "제목을 지어주세요." : chapter.title
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
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
