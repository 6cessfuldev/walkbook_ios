class StoryMapper {
    static func toEntity(_ model: StoryModel) -> Story {
        return Story(
            id: model.id,
            title: model.title,
            authorId: model.authorId,
            imageUrl: model.imageUrl,
            description: model.description, rootChapterId: model.rootChapterId
        )
    }

    static func toModel(_ entity: Story) -> StoryModel {
        return StoryModel(
            id: entity.id,
            title: entity.title,
            authorId: entity.authorId,
            imageUrl: entity.imageUrl,
            description: entity.description,
            rootChapterId: entity.rootChapterId
        )
    }
}
