import FirebaseFirestoreInternal

class UserProfileMapper {
    static func toEntity(_ model: UserProfileModel) -> UserProfile {
        return UserProfile(
            id: model.id,
            provider: model.provider,
            name: model.name,
            nickname: model.nickname,
            imageUrl: model.imageUrl,
            createdAt: model.createdAt?.dateValue(),
            updatedAt: model.updatedAt?.dateValue()
        )
    }

    static func toModel(_ entity: UserProfile) -> UserProfileModel {
        return UserProfileModel(
            id: entity.id,
            provider: entity.provider,
            name: entity.name,
            nickname: entity.nickname,
            imageUrl: entity.imageUrl,
            createdAt: entity.createdAt != nil ? Timestamp(date: entity.createdAt!) : nil,
            updatedAt: entity.updatedAt != nil ? Timestamp(date: entity.updatedAt!) : nil
        )
    }
}
