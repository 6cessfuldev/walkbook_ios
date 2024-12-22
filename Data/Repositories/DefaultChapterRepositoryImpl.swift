import Foundation

class DefaultChapterRepositoryImpl: ChapterRepository {
    private let chapterRemoteDataSource: ChapterRemoteDataSource
    private let storyRemoteDataSource: StoryRemoteDataSource
    
    init(chapterRemoteDataSource: ChapterRemoteDataSource, storyRemoteDataSource: StoryRemoteDataSource) {
        self.chapterRemoteDataSource = chapterRemoteDataSource
        self.storyRemoteDataSource = storyRemoteDataSource
    }
    
    func createChapter(_ chapter: Chapter, completion: @escaping (Result<Chapter, Error>) -> Void) {
        chapterRemoteDataSource.add(chapter: ChapterMapper.toModel(chapter)) { result in
            switch result {
            case .success(let model):
                completion(.success(ChapterMapper.toEntity(model)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createRootChapter(_ chapter: Chapter, storyId: String, completion: @escaping (Result<Chapter, Error>) -> Void) {
        chapter.storyId = storyId
        chapterRemoteDataSource.add(chapter: ChapterMapper.toModel(chapter)) { r in
            switch r {
            case .success(let model):
                guard let chapterId = model.id else {
                    completion(.failure(NSError(domain: "Chapter ID Doesn't Exist", code: -1, userInfo: nil)))
                    return
                }
                self.storyRemoteDataSource.updateRootChapter(storyId: storyId, chapterId: chapterId) { updateRes in
                    switch updateRes {
                    case .success(()):
                        completion(.success(ChapterMapper.toEntity(model)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createChildChapter(_ child: Chapter, to parentChapterId: String, completion: @escaping (Result<Chapter, Error>) -> Void) {
        chapterRemoteDataSource.addChildChapter(ChapterMapper.toModel(child), to: parentChapterId) { r in
            switch r {
            case .success(let model):
                completion(.success(ChapterMapper.toEntity(model)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchChapterInStory(by storyId: String, completion: @escaping (Result<NestedChapter, Error>) -> Void) {
        chapterRemoteDataSource.fetchByStoryId(by: storyId) { result in
            switch result {
            case .success(let models):
                let nestedChapter = ChapterTreeBuilder.buildTree(flatChapters: models)
                guard let nestedChapter = nestedChapter else {
                    completion(.failure(NSError(domain: "ChapterTreeBuildError", code: -1, userInfo: nil)))
                    return
                }
                completion(.success(nestedChapter))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let chapterId = chapter.id else {
            completion(.failure(NSError(domain: "Not Found Chapter ID", code: -1, userInfo: nil)))
            return
        }
        chapterRemoteDataSource.update(chapter: ChapterMapper.toModel(chapter), with: chapterId, completion: completion)
    }
    
}
