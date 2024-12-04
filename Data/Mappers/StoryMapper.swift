class StoryMapper {
    static func toEntity(_ model: StoryModel) -> Story {
        return Story(
            id: model.id,
            title: model.title,
            author: model.author,
            imageUrl: model.imageUrl,
            description: model.description
        )
    }

    static func toModel(_ entity: Story) -> StoryModel {
        return StoryModel(
            id: entity.id,
            title: entity.title,
            author: entity.author,
            imageUrl: entity.imageUrl,
            description: entity.description
        )
    }
}
