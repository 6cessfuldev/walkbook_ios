import Foundation

protocol StoryUseCaseProtocol {
    func createStory(_ story: Story, completion: @escaping (Result<Story, Error>) -> Void)
    func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void)
    func fetchMyStories(completion: @escaping (Result<[Story], Error>) -> Void)
    func updateStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteStory(byId id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultStoryUseCase: StoryUseCaseProtocol {
    
    private let storyRepository: StoryRepository
    private let sessionRepository: SessionRepository
    
    init(storyRepository: StoryRepository, sessionRepository: SessionRepository) {
        self.storyRepository = storyRepository
        self.sessionRepository = sessionRepository
    }

    func createStory(_ story: Story, completion: @escaping (Result<Story, Error>) -> Void) {
        storyRepository.addStory(story, completion: completion)
    }

    func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void) {
        storyRepository.fetchStories(completion: completion)
    }
        
    func fetchMyStories(completion: @escaping (Result<[Story], Error>) -> Void) {
        let result = self.sessionRepository.getUserProfile().map { $0.id }
        switch result {
        case .success(let authorId):
            storyRepository.fetchStoriesByAuthorId(id: authorId, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
        
    }

    func updateStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void) {
        storyRepository.updateStory(story, completion: completion)
    }

    func deleteStory(byId id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        storyRepository.deleteStory(byId: id, completion: completion)
    }
}
