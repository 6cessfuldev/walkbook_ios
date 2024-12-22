import UIKit
import RxSwift
import RxCocoa

class EditChapterListViewController: UIViewController {

    private let viewModel: EditChapterListViewModel
    weak var coordinator: MainFlowCoordinator!
    
    private let disposeBag = DisposeBag()
    
    private let tableView = UITableView()

    init(viewModel: EditChapterListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        navigationItem.title = "챕터 목록"
    }

    private func setupUI() {
        view.backgroundColor = .background

        tableView.backgroundColor = .background
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChapterCollectionViewTableViewCell.self, forCellReuseIdentifier: "ChapterCollectionViewTableViewCell")
        tableView.register(AddChapterTableViewCell.self, forCellReuseIdentifier: "AddChapterTableViewCell")
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }

    private func bindViewModel() {
        viewModel.chapterStateRelay
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension EditChapterListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.chapterStateRelay.value.chapterLevels.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.chapterStateRelay.value.chapterLevels.count <= indexPath.section {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddChapterTableViewCell", for: indexPath) as? AddChapterTableViewCell else {
                return UITableViewCell()
            }
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterCollectionViewTableViewCell", for: indexPath) as? ChapterCollectionViewTableViewCell else {
            return UITableViewCell()
        }

        let chapters = viewModel.chapterStateRelay.value.chapterLevels[indexPath.section]
        let selectedChapterIndex = viewModel.chapterStateRelay.value.selectedChapterLevels[indexPath.section]
        cell.configure(with: chapters, currentIndex: selectedChapterIndex, level: indexPath.section)

        cell.displayedChapter
            .subscribe(onNext: { [weak self] index in
                self?.viewModel.updateChapterLevels(from: indexPath.section, selectedIndex: index)
            })
            .disposed(by: cell.disposeBag)

        cell.addButtonAction
            .subscribe(onNext: { [weak self] in
                self?.addChapter(at: indexPath.section)
            })
            .disposed(by: cell.disposeBag)
        
        cell.selectButtonAction
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                guard let selectedChapter = self.viewModel.getSelectedChapter(level: indexPath.section) else {
                    print("getSelectedChapter error")
                    return
                }
                self.coordinator.showEditChapterVC(chapter: selectedChapter)
            })
            .disposed(by: cell.disposeBag)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.chapterStateRelay.value.chapterLevels.count == indexPath.section {
            addChapter(at: indexPath.section)
        }
    }

    private func addChapter(at level: Int) {
        let addChapterVC = AddChapterViewController()
        addChapterVC.modalPresentationStyle = .overFullScreen

        addChapterVC.onSave = { [weak self] title in
            self?.viewModel.addOtherChapter(level: level, title: title)
        }

        present(addChapterVC, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.chapterStateRelay.value.chapterLevels.count <= indexPath.section ? 50 : 80
    }
}
