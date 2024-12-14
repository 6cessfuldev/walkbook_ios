import CoreLocation

class Chapter {
    let id: String?
    var title: String
    var imageUrl: String?
    var description: String?
    var unlockCondition: Condition?
    var cosumeCondition: Condition?
    var location: CLLocationCoordinate2D?
    var radius: Double?
    var steps: [Step]
    var childChapter: [Chapter]
    var nextChapterID: String?
    
    init(id: String? = nil,
         title: String,
         imageUrl: String? = nil,
         description: String? = nil,
         unlockCondition: Condition? = nil,
         cosumeCondition: Condition? = nil,
         location: CLLocationCoordinate2D? = nil,
         radius: Double? = nil,
         steps: [Step] = [],
         childChapter: [Chapter] = [],
         nextChapterID: String? = nil) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.description = description
        self.unlockCondition = unlockCondition
        self.cosumeCondition = cosumeCondition
        self.location = location
        self.radius = radius
        self.steps = steps
        self.childChapter = childChapter
        self.nextChapterID = nextChapterID
    }
}
