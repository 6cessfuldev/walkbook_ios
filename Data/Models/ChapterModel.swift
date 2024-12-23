import FirebaseFirestore

struct ChapterModel: Codable {
    var id: String?
    var storyId: String?
    var title: String
    var imageUrl: String?
    var description: String?
    var location: GeoPoint?
    var radius: Double?
    var steps: [String]
    var childChapters: [String]

    init(
        id: String? = nil,
        storyId: String? = nil,
        title: String,
        imageUrl: String? = nil,
        description: String? = nil,
        location: GeoPoint? = nil,
        radius: Double? = nil,
        steps: [String] = [],
        childChapters: [String] = []
    ) {
        self.id = id
        self.storyId = storyId
        self.title = title
        self.imageUrl = imageUrl
        self.description = description
        self.location = location
        self.radius = radius
        self.steps = steps
        self.childChapters = childChapters
    }
    
    func copy(
        id: String? = nil,
        storyId: String? = nil,
        title: String? = nil,
        imageUrl: String? = nil,
        description: String? = nil,
        location: GeoPoint? = nil,
        radius: Double? = nil,
        steps: [String]? = nil,
        childChapters: [String]? = nil
    ) -> ChapterModel {
        return ChapterModel(
            id: id ?? self.id,
            storyId: storyId ?? self.storyId,
            title: title ?? self.title,
            imageUrl: imageUrl ?? self.imageUrl,
            description: description ?? self.description,
            location: location ?? self.location,
            radius: radius ?? self.radius,
            steps: steps ?? self.steps,
            childChapters: childChapters ?? self.childChapters
        )
    }
}
