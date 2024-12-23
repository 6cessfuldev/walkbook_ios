import Foundation
struct UserProfile: Equatable {
    let id: String
    let provider: String
    let name: String?
    let nickname: String?
    let imageUrl: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(id: String, provider: String, name: String?, nickname: String?, imageUrl: String?, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.provider = provider
        self.name = name
        self.nickname = nickname
        self.imageUrl = imageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
