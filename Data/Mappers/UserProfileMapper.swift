class UserProfileMapper {
    static func toEntity(_ model: UserProfileModel) -> UserProfile {
        return UserProfile(
            id: model.id,
            provider: model.provider,
            name: model.name,
            nickname: model.nickname,
            imageUrl: model.imageUrl
        )
    }

    static func toModel(_ entity: UserProfile) -> UserProfileModel {
        return UserProfileModel(
            id: entity.id,
            provider: entity.provider,
            name: entity.name,
            nickname: entity.nickname,
            imageUrl: entity.imageUrl
        )
    }
}
