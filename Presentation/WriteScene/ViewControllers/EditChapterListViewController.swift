import UIKit
import RxSwift
import RxCocoa

class EditChapterListViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let rootChapter: Chapter = {
        // Level 3
        let chapter1_2_1_1 = Chapter(id: "1_2_1_1", title: "chapter1_2_1_1", steps: [], childChapter: [])
        let chapter1_2_2_1 = Chapter(id: "1_2_2_1", title: "chapter1_2_2_1", steps: [], childChapter: [])
        let chapter1_3_1_1 = Chapter(id: "1_3_1_1", title: "chapter1_3_1_1", steps: [], childChapter: [])
        
        // Level 2
        let chapter1_2_1 = Chapter(id: "1_2_1", title: "chapter1_2_1", steps: [], childChapter: [chapter1_2_1_1])
        let chapter1_2_2 = Chapter(id: "1_2_2", title: "chapter1_2_2", steps: [], childChapter: [chapter1_2_2_1])
        let chapter1_3_1 = Chapter(id: "1_3_1", title: "chapter1_3_1", steps: [], childChapter: [chapter1_3_1_1])
        
        // Level 1
        let chapter1_1 = Chapter(id: "1_1", title: "chapter1_1", steps: [], childChapter: [])
        let chapter1_2 = Chapter(id: "1_2", title: "chapter1_2", steps: [], childChapter: [chapter1_2_1, chapter1_2_2])
        let chapter1_3 = Chapter(id: "1_3", title: "chapter1_3", steps: [], childChapter: [chapter1_3_1])
        let chapter1_4 = Chapter(id: "1_4", title: "chapter1_4", steps: [], childChapter: [])
        
        // Level 0 (Root)
        return Chapter(id: "1", title: "chapter1", steps: [], childChapter: [chapter1_1, chapter1_2, chapter1_3, chapter1_4])
    }()
    
    private let tableView = UITableView()
    private var chapterLevels: [[Chapter]] = []
    private var selectedChapterLevels: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        prepareChapterLevels()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChapterCollectionViewTableViewCell.self, forCellReuseIdentifier: "ChapterCollectionViewTableViewCell")
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
    private func prepareChapterLevels() {
        func buildLevels(from chapter: Chapter, level: Int) {
            if chapterLevels.count <= level {
                chapterLevels.append([])
                selectedChapterLevels.append(0)
            }

            if !chapterLevels[level].contains(where: { $0.id == chapter.id }) {
                chapterLevels[level].append(chapter)
            }

            if !chapter.childChapter.isEmpty {
                if chapterLevels.count <= level + 1 {
                    chapterLevels.append([])
                }

                chapterLevels[level + 1].append(contentsOf: chapter.childChapter)

                let selectedChild = chapter.childChapter[selectedChapterLevels[level]]
                buildLevels(from: selectedChild, level: level + 1)
            }
        }

        chapterLevels.removeAll()

        buildLevels(from: rootChapter, level: 0)
        selectedChapterLevels.append(0)
    }
    
    private func updateChapterLevels(from level: Int, selectedIndex index: Int) {
        
        guard level < chapterLevels.count else { return }
        guard level < selectedChapterLevels.count else { return }
        
        selectedChapterLevels[level] = index
        for i in (level + 1)..<self.selectedChapterLevels.count {
            self.selectedChapterLevels[i] = 0
        }

        chapterLevels = Array(chapterLevels.prefix(level+1))
        selectedChapterLevels = Array(selectedChapterLevels.prefix(level+1))

        func buildLevels(level: Int) {
            if chapterLevels.count <= level {
                chapterLevels.append([])
            }
            
            if selectedChapterLevels.count <= level {
                selectedChapterLevels.append(0)
            }
            
            let selectedChapter = chapterLevels[level][selectedChapterLevels[level]]
            
            guard !selectedChapter.childChapter.isEmpty else { return }

            if chapterLevels.count <= level + 1 {
                chapterLevels.append([])
            }

            chapterLevels[level + 1].append(contentsOf: selectedChapter.childChapter)

            buildLevels(level: level + 1)
        }

        buildLevels(level: level)
    }
}

extension EditChapterListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return chapterLevels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt called for section: \(indexPath.section), row: \(indexPath.row)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterCollectionViewTableViewCell", for: indexPath) as? ChapterCollectionViewTableViewCell else {
            return UITableViewCell()
        }
        let chapters = chapterLevels[indexPath.section]
        cell.configure(with: chapters, currentIndex: self.selectedChapterLevels[indexPath.section])
        
        cell.displayedChapter
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                print("row : \(indexPath.section) selectedIndex: \(index) chapters.count : \(chapters.count) chapterLevels.count \(chapterLevels.count)")
                
                let lastChapterLevelCount = self.chapterLevels.count
                
                self.updateChapterLevels(from: indexPath.section, selectedIndex: index)

                let deleteRange = (indexPath.section + 1)..<lastChapterLevelCount
                let sectionsToDelete = IndexSet(deleteRange)

                let sectionsToInsert = IndexSet(indexPath.section + 1..<self.chapterLevels.count)

                let currentSections = tableView.numberOfSections

                tableView.beginUpdates()

                if let maxSection = sectionsToDelete.max(), maxSection < currentSections {
                    print("Deleting sections: \(sectionsToDelete)")
                    tableView.deleteSections(sectionsToDelete, with: .fade)
                } else {
                    print("Skipping delete: Invalid sectionsToDelete \(sectionsToDelete)")
                }

                if !sectionsToInsert.isEmpty {
                    print("Inserting sections: \(sectionsToInsert)")
                    tableView.insertSections(sectionsToInsert, with: .fade)
                } else {
                    print("Skipping insert: Invalid sectionsToInsert \(sectionsToInsert)")
                }
                tableView.endUpdates()

            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    private func deleteSections(at indexes: [Int]) {
        let sortedIndexes = indexes.sorted(by: >)
        let indexSet = IndexSet(sortedIndexes)

        tableView.beginUpdates()

        for index in sortedIndexes {
            chapterLevels.remove(at: index)
        }

        tableView.deleteSections(indexSet, with: .automatic)

        tableView.endUpdates()
    }
}
