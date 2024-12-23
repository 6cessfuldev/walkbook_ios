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
    
    func copy(
        id: String? = nil,
        title: String? = nil,
        authorId: String? = nil,
        imageUrl: String? = nil,
        description: String? = nil,
        rootChapterId: String? = nil
    ) -> StoryModel {
        return StoryModel(
            id: id ?? self.id,
            title: title ?? self.title,
            authorId: authorId ?? self.authorId,
            imageUrl: imageUrl ?? self.imageUrl,
            description: description ?? self.description,
            rootChapterId: rootChapterId ?? self.rootChapterId
        )
    }
}
