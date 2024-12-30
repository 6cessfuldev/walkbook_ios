import FirebaseFirestore

struct ChapterModel: Codable {
    let id: String?
    let storyId: String?
    let title: String
    let imageUrl: String?
    let description: String?
    let location: GeoPoint?
    let radius: Double?
    let steps: [String]
    let childChapters: [String]
    let duration: Int?
    let createdAt: Timestamp?
    let updatedAt: Timestamp?

    init(
        id: String? = nil,
        storyId: String? = nil,
        title: String,
        imageUrl: String? = nil,
        description: String? = nil,
        location: GeoPoint? = nil,
        radius: Double? = nil,
        steps: [String] = [],
        childChapters: [String] = [],
        duration: Int? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil
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
        self.duration = duration
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
        childChapters: [String]? = nil,
        duration: Int? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil
        
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
            childChapters: childChapters ?? self.childChapters,
            duration: duration ?? self.duration,
            createdAt: createdAt ?? self.createdAt,
            updatedAt: updatedAt ?? self.updatedAt
        )
    }
}
