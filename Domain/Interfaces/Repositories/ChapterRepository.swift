protocol ChapterRepository {
    func createChapter(_ chapter: Chapter, completion: @escaping (Result<Chapter, Error>) -> Void)
    func createRootChapter(_ chapter: Chapter, storyId: String, completion: @escaping (Result<Chapter, Error>) -> Void)
    func createChildChapter(_ child: Chapter, to parentChapterId: String, completion: @escaping (Result<Chapter, Error>) -> Void)
    func fetchChapterInStory(by storyId: String, completion: @escaping (Result<NestedChapter, Error>) -> Void)
    func updateChapter(_ chapter: Chapter, completion: @escaping (Result<Void, Error>) -> Void)
}
