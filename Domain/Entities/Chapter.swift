import CoreLocation

struct Chapter {
    let id: String?
    var title: String
    var imageUrl: String?
    var description: String?
    var unlockCondition: Condition?
    var cosumeCondition: Condition?
    var location: CLLocationCoordinate2D?
    var radius: Double?
    var steps: [Step]
    let childChapter: [Chapter]
    var nextChapterID: String?
}
