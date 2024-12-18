protocol ChapterRepository {
    func createChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchChapterInStory(by storyId: String, completion: @escaping (Result<Chapter, Error>) -> Void)
    func updateChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void)
}
