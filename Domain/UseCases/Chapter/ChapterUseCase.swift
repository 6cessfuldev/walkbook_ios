import Foundation

protocol ChapterUseCaseProtocol {
    func createChapter(_ chapter: Chapter, completion: @escaping (Result<Chapter, Error>) -> Void)
    func createRootChapter(_ chapter: Chapter, storyId: String, completion: @escaping (Result<Chapter, Error>) -> Void)
    func createChildChapter(_ child: Chapter, to parentChapterId: String, completion: @escaping (Result<Chapter, Error>) -> Void)
    func fetchChapterInStory(by storyId: String, completion: @escaping (Result<NestedChapter, Error>) -> Void)
    func updateChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultChapterUseCase: ChapterUseCaseProtocol {
    private let chapterRepository: ChapterRepository
    
    init(chapterRepository: ChapterRepository) {
        self.chapterRepository = chapterRepository
    }
    
    func createChapter(_ chapter: Chapter, completion: @escaping (Result<Chapter, Error>) -> Void) {
        chapterRepository.createChapter(chapter, completion: completion)
    }
    
    func createRootChapter(_ chapter: Chapter, storyId: String, completion: @escaping (Result<Chapter, Error>) -> Void) {
        chapterRepository.createRootChapter(chapter, storyId: storyId, completion: completion)
    }
    
    func createChildChapter(_ child: Chapter, to parentChapterId: String, completion: @escaping (Result<Chapter, Error>) -> Void) {
        chapterRepository.createChildChapter(child, to: parentChapterId, completion: completion)
    }
    
    func fetchChapterInStory(by storyId: String, completion: @escaping (Result<NestedChapter, Error>) -> Void) {
        chapterRepository.fetchChapterInStory(by: storyId, completion: completion)
    }
    
    func updateChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void) {
        chapterRepository.updateChapter(chapter, completion: completion)
    }
}
