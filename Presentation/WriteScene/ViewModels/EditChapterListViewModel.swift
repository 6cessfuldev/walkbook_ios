import RxSwift
import RxCocoa

class EditChapterListViewModel {
    private let disposeBag = DisposeBag()

    let chapterLevelsRelay = BehaviorRelay<[[Chapter]]>(value: [])
    let selectedChapterLevelsRelay = BehaviorRelay<[Int]>(value: [])

    private let rootChapter: Chapter = Chapter(title: "")
    
    init() {
        prepareChapterLevels()
    }
    
    func getSelectedChapter(level: Int) -> Chapter {
        return chapterLevelsRelay.value[level][selectedChapterLevelsRelay.value[level]]
    }

    private func prepareChapterLevels() {
        var chapterLevels: [[Chapter]] = []
        var selectedChapterLevels: [Int] = []
        
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
        
        buildLevels(from: rootChapter, level: 0)
        selectedChapterLevels.append(0)
        
        chapterLevelsRelay.accept(chapterLevels)
        selectedChapterLevelsRelay.accept(selectedChapterLevels)
    }

    func updateChapterLevels(from level: Int, selectedIndex index: Int) {
        var chapterLevels = chapterLevelsRelay.value
        var selectedChapterLevels = selectedChapterLevelsRelay.value

        guard level < chapterLevels.count, level < selectedChapterLevels.count else { return }

        selectedChapterLevels[level] = index
        for i in (level + 1)..<selectedChapterLevels.count {
            selectedChapterLevels[i] = 0
        }

        chapterLevels = Array(chapterLevels.prefix(level + 1))
        selectedChapterLevels = Array(selectedChapterLevels.prefix(level + 1))

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
        chapterLevelsRelay.accept(chapterLevels)
        selectedChapterLevelsRelay.accept(selectedChapterLevels)
    }

    func addOtherChapter(level: Int, title: String) {
        var chapterLevels = chapterLevelsRelay.value
        var selectedChapterLevels = selectedChapterLevelsRelay.value

        guard level > 0, level < chapterLevels.count + 1 else { return }
        
        let newChapter = Chapter(id: nil, title: title, steps: [], childChapter: [])
        chapterLevels[level - 1][selectedChapterLevels[level - 1]].childChapter.append(newChapter)
        
        if(level == chapterLevels.count) {
            chapterLevels.append([])
            selectedChapterLevels.append(0)
        }
        chapterLevels[level].append(newChapter)

        chapterLevelsRelay.accept(chapterLevels)
        selectedChapterLevelsRelay.accept(selectedChapterLevels)
    }
}
