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
    
    func copy(
        id: String? = nil,
        provider: String? = nil,
        name: String? = nil,
        nickname: String? = nil,
        imageUrl: String? = nil,
        lastLoginDate: Date? = nil
    ) -> UserProfileModel {
        return UserProfileModel(
            id: id ?? self.id,
            provider: provider ?? self.provider,
            name: name ?? self.name,
            nickname: nickname ?? self.nickname,
            imageUrl: imageUrl ?? self.imageUrl,
            lastLoginDate: lastLoginDate ?? self.lastLoginDate
        )
    }
}
