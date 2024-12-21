class DefaultStoryRepositoryImpl: StoryRepository {
    
    private let storyRemoteDataSource: StoryRemoteDataSource
    
    init(storyRemoteDataSource: StoryRemoteDataSource) {
        self.storyRemoteDataSource = storyRemoteDataSource
    }
    
    func addStory(_ story: Story, completion: @escaping (Result<Story, Error>) -> Void) {
        let model = StoryMapper.toModel(story)
        
        storyRemoteDataSource.add(story: model) { result in
            switch result {
            case .success(let model):
                completion(.success(StoryMapper.toEntity(model)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void) {
        storyRemoteDataSource.fetchAll { result in
            switch result {
            case .success(let models):
                let entities = models.map { StoryMapper.toEntity($0) }
                completion(.success(entities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchStoriesByAuthorId(id: String, completion: @escaping (Result<[Story], Error>) -> Void) {
        storyRemoteDataSource.fetchAll { result in
            switch result {
            case .success(let models):
                let entities = models.map { StoryMapper.toEntity($0) }
                completion(.success(entities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = story.id else {
            completion(.failure(BadRequestError.missingID))
            return
        }
        
        let model = StoryMapper.toModel(story)
        
        storyRemoteDataSource.update(story: model, with: id) { result in
            completion(result)
        }
    }
    
    func deleteStory(byId id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        storyRemoteDataSource.delete(by: id) { result in
            completion(result)
        }
    }
}
