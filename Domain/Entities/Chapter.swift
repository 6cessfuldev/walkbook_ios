import CoreLocation

class Chapter {
    let id: String?
    var storyId: String?
    var title: String
    var imageUrl: String?
    var description: String?
    var location: CLLocationCoordinate2D?
    var radius: Double?
    var steps: [String]
    var childChapters: [String]
    let createdAt: Date?
    let updatedAt: Date?
    
    init(id: String? = nil,
         storyId: String? = nil,
         title: String,
         imageUrl: String? = nil,
         description: String? = nil,
         location: CLLocationCoordinate2D? = nil,
         radius: Double? = nil,
         steps: [String] = [],
         childChapters: [String] = [],
         createdAt: Date? = nil,
         updatedAt: Date? = nil) {
        self.id = id
        self.storyId = storyId
        self.title = title
        self.imageUrl = imageUrl
        self.description = description
        self.location = location
        self.radius = radius
        self.steps = steps
        self.childChapters = childChapters
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    static func fromNestedChapter(_ nestedChapter: NestedChapter) -> Chapter {
        return Chapter(
            id: nestedChapter.id,
            storyId: nestedChapter.storyId,
            title: nestedChapter.title,
            imageUrl: nestedChapter.imageUrl,
            description: nestedChapter.description,
            location: nestedChapter.location,
            radius: nestedChapter.radius,
            steps: nestedChapter.steps,
            childChapters: nestedChapter.childChapters.compactMap { $0.id },
            createdAt: nestedChapter.createdAt,
            updatedAt: nestedChapter.updatedAt
        )
    }
}
