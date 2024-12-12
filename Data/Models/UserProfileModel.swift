import Foundation

struct UserProfileModel: Codable {
    let id: String
    let provider: String
    let name: String?
    let nickname: String?
    let imageUrl: String?
    var lastLoginDate: Date?

    init(id: String, provider: String, name: String? = nil, nickname: String? = nil, imageUrl: String? = nil, lastLoginDate: Date? = nil) {
        self.id = id
        self.provider = provider
        self.name = name
        self.nickname = nickname
        self.imageUrl = imageUrl
        self.lastLoginDate = lastLoginDate
    }
}
