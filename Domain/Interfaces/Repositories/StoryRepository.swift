protocol StoryRepository {
    func addStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchStories(completion: @escaping (Result<[Story], Error>) -> Void)
    func fetchStoriesByAuthorId(id: String, completion:  @escaping (Result<[Story], Error>) -> Void)
    func updateStory(_ story: Story, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteStory(byId id: String, completion: @escaping (Result<Void, Error>) -> Void)
}
