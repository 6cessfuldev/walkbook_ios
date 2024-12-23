import FirebaseFirestoreInternal

struct StoryModel: Codable {
    let id: String?
    let title: String
    let authorId: String
    let imageUrl: String
    let description: String
    let rootChapterId: String?
    let createdAt: Timestamp?
    let updatedAt: Timestamp?

    init(id: String? = nil, title: String, authorId: String, imageUrl: String, description: String, rootChapterId: String?, createdAt: Timestamp?, updatedAt: Timestamp?) {
        self.id = id
        self.title = title
        self.authorId = authorId
        self.imageUrl = imageUrl
        self.description = description
        self.rootChapterId = rootChapterId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func copy(
        id: String? = nil,
        title: String? = nil,
        authorId: String? = nil,
        imageUrl: String? = nil,
        description: String? = nil,
        rootChapterId: String? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil
    ) -> StoryModel {
        return StoryModel(
            id: id ?? self.id,
            title: title ?? self.title,
            authorId: authorId ?? self.authorId,
            imageUrl: imageUrl ?? self.imageUrl,
            description: description ?? self.description,
            rootChapterId: rootChapterId ?? self.rootChapterId,
            createdAt: createdAt ?? self.createdAt,
            updatedAt: updatedAt ?? self.updatedAt
        )
    }
}
