struct StoryModel: Codable {
    var id: String?
    var title: String
    var authorId: String
    var imageUrl: String
    var description: String
    var rootChapterId: String?

    init(id: String? = nil, title: String, authorId: String, imageUrl: String, description: String, rootChapterId: String?) {
        self.id = id
        self.title = title
        self.authorId = authorId
        self.imageUrl = imageUrl
        self.description = description
        self.rootChapterId = rootChapterId
    }
}
