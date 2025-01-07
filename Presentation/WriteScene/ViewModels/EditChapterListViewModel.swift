import RxSwift
import RxCocoa

class EditChapterListViewModel {
    private let disposeBag = DisposeBag()

    let chapterStateRelay = BehaviorRelay<(chapterLevels: [[NestedChapter]], selectedChapterLevels: [Int])>(
        value: (chapterLevels: [], selectedChapterLevels: [])
    )
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    
    private let storyId: String
    private(set) var rootChapter: NestedChapter = NestedChapter(title: "")
    
    private let chapterUseCase: ChapterUseCaseProtocol
    
    init(storyId: String, chapterUseCase: ChapterUseCaseProtocol) {
        self.storyId = storyId
        self.chapterUseCase = chapterUseCase
        fetchRootChapter()
    }
    
    private func updateChapterState(
        chapterLevels: [[NestedChapter]],
        selectedChapterLevels: [Int]
    ) {
        chapterStateRelay.accept((chapterLevels, selectedChapterLevels))
    }
    
    private func fetchRootChapter() {
        isLoading.accept(true)
        
        chapterUseCase.fetchChapterInStory(by: storyId) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading.accept(false)
            switch result {
            case .success(let chapter):
                self.rootChapter = chapter
                self.prepareChapterLevels()
            case .failure(let error):
                self.errorMessage.accept("Failed to load root chapter: \(error.localizedDescription)")
            }
        }
    }
    
    func getSelectedChapter(level: Int) -> NestedChapter? {
        let currentState = chapterStateRelay.value
        let chapterLevels = currentState.chapterLevels
        let selectedChapterLevels = currentState.selectedChapterLevels
        
        guard level < chapterLevels.count else {
            print("Error: Level \(level) is out of range for chapterLevels.")
            return nil
        }
        
        let chaptersAtLevel = chapterLevels[level]
        
        guard level < selectedChapterLevels.count else {
            print("Error: No selected index for level \(level).")
            return nil
        }
        
        let selectedIndex = selectedChapterLevels[level]
        guard selectedIndex < chaptersAtLevel.count else {
            print("Error: Selected index \(selectedIndex) is out of range for level \(level).")
            return nil
        }
        
        return chaptersAtLevel[selectedIndex]
    }

    private func prepareChapterLevels() {
        var chapterLevels: [[NestedChapter]] = []
        var selectedChapterLevels: [Int] = []
        
        func buildLevels(from chapter: NestedChapter, level: Int) {
            if chapterLevels.count <= level {
                chapterLevels.append([])
            }
            
            if selectedChapterLevels.count <= level {
                selectedChapterLevels.append(0)
            }

            if !chapterLevels[level].contains(where: { $0.id == chapter.id }) {
                chapterLevels[level].append(chapter)
            }

            if !chapter.childChapters.isEmpty {
                if chapterLevels.count <= level + 1 {
                    chapterLevels.append([])
                }

                chapterLevels[level + 1].append(contentsOf: chapter.childChapters)

                let selectedChild = chapter.childChapters[selectedChapterLevels[level]]
                buildLevels(from: selectedChild, level: level + 1)
            }
        }
        
        buildLevels(from: rootChapter, level: 0)
        selectedChapterLevels.append(0)
        
        updateChapterState(chapterLevels: chapterLevels, selectedChapterLevels: selectedChapterLevels)
    }

    func updateChapterLevels(from level: Int, selectedIndex index: Int) {
        var chapterLevels = chapterStateRelay.value.chapterLevels
        var selectedChapterLevels = chapterStateRelay.value.selectedChapterLevels
        
        print("chapterLevels[0]: \(chapterLevels[0])")

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

            guard !selectedChapter.childChapters.isEmpty else { return }

            if chapterLevels.count <= level + 1 {
                chapterLevels.append([])
            }

            chapterLevels[level + 1].append(contentsOf: selectedChapter.childChapters)

            buildLevels(level: level + 1)
        }

        buildLevels(level: level)
        updateChapterState(chapterLevels: chapterLevels, selectedChapterLevels: selectedChapterLevels)
    }

    func addOtherChapter(level: Int, title: String) {
        var chapterLevels = chapterStateRelay.value.chapterLevels
        var selectedChapterLevels = chapterStateRelay.value.selectedChapterLevels

        guard level >= 0, level < chapterLevels.count + 1 else { return }
        
        let newChapter = Chapter(id: nil, storyId: self.storyId, title: title, steps: [], childChapters: [])
        
        if(level == 0) {
            chapterUseCase.createRootChapter(newChapter, storyId: storyId) { r in
                switch r {
                case .success(let chapter):
                    self.rootChapter = NestedChapter.fromChapter(chapter)
                    self.prepareChapterLevels()
                case .failure(let error):
                    print("error: \(error)")
                    self.errorMessage.accept("Chapter 저장에 실패했습니다.")
                }
            }
        } else {
            guard let parentChapterId = chapterLevels[level - 1][selectedChapterLevels[level - 1]].id else {
                print("error: 부모 챕터의 ID를 찾을 수 없습니다.")
                self.errorMessage.accept("부모 챕터의 ID를 찾을 수 없습니다.")
                return
            }
            
            chapterUseCase.createChildChapter(newChapter, to: parentChapterId) { result in
                switch result {
                case .success(let chapter):
                    let newNestedChapter = NestedChapter.fromChapter(chapter)
                    
                    chapterLevels[level - 1][selectedChapterLevels[level - 1]].childChapters.append(newNestedChapter)
                    
                    if(level == chapterLevels.count) {
                        chapterLevels.append([])
                        selectedChapterLevels.append(0)
                    }
                    chapterLevels[level].append(newNestedChapter)
                    
                    self.updateChapterState(chapterLevels: chapterLevels, selectedChapterLevels: selectedChapterLevels)
                
                case .failure(let error):
                    print("error: \(error)")
                    self.errorMessage.accept("Chapter 저장에 실패했습니다.")
                }
            }
        }
        
        
    }
}
