import Foundation

protocol StoryUseCaseProtocol {
    func createStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void)
    func fetchMyStories(by authorId: String, completion: @escaping (Result<[Story], Error>) -> Void)
    func updateStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteStory(byId id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultStoryUseCase: StoryUseCaseProtocol {
    
    private let repository: StoryRepository
    
    init(repository: StoryRepository) {
        self.repository = repository
    }

    func createStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.addStory(story, completion: completion)
    }

    func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void) {
        repository.fetchStories(completion: completion)
    }
        
    func fetchMyStories(by authorId: String, completion: @escaping (Result<[Story], Error>) -> Void) {
        repository.fetchStoriesByAuthorId(id: authorId, completion: completion)
    }

    func updateStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.updateStory(story, completion: completion)
    }

    func deleteStory(byId id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.deleteStory(byId: id, completion: completion)
    }
}
