import Foundation

protocol ChapterUseCase {
    func createChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchChapterInStory(by storyId: String, completion: @escaping (Result<Chapter, Error>) -> Void)
    func updateChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultChapterUseCase: ChapterUseCase {
    private let chapterRepository: ChapterRepository
    
    init(chapterRepository: ChapterRepository) {
        self.chapterRepository = chapterRepository
    }
    
    func createChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void) {
        chapterRepository.createChapter(chapter, completion: completion)
    }
    
    func fetchChapterInStory(by storyId: String, completion: @escaping (Result<Chapter, Error>) -> Void) {
        chapterRepository.fetchChapterInStory(by: storyId, completion: completion)
    }
    
    func updateChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void) {
        chapterRepository.updateChapter(chapter, completion: completion)
    }
}
