import CoreLocation

class NestedChapter {
    let id: String?
    var storyId: String?
    var title: String
    var imageUrl: String?
    var description: String?
    var location: CLLocationCoordinate2D?
    var radius: Double?
    var steps: [String]
    var childChapters: [NestedChapter]
    
    init(id: String? = nil,
         storyId: String? = nil,
         title: String,
         imageUrl: String? = nil,
         description: String? = nil,
         location: CLLocationCoordinate2D? = nil,
         radius: Double? = nil,
         steps: [String] = [],
         childChapters: [NestedChapter] = []) {
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
    
    static func fromChapter(_ chapter: Chapter) -> NestedChapter {
        return NestedChapter(
            id: chapter.id,
            storyId: chapter.storyId,
            title: chapter.title,
            imageUrl: chapter.imageUrl,
            description: chapter.description,
            location: chapter.location,
            radius: chapter.radius,
            steps: chapter.steps,
            childChapters: []
        )
    }
}
