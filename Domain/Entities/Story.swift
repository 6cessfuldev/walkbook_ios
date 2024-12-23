import Foundation

struct Story {
    let id: String?
    let title: String
    let authorId: String
    let imageUrl: String
    let description: String
    let rootChapterId: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(id: String?, title: String, authorId: String, imageUrl: String, description: String, rootChapterId: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.authorId = authorId
        self.imageUrl = imageUrl
        self.description = description
        self.rootChapterId = rootChapterId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
