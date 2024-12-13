import CoreLocation

enum StepType {
    case text(String)
    case music(String)
    case video(String)
    case image(String)
    case mission(location: CLLocationCoordinate2D, radius: Double)
    case question(correctAnswer: String, options: [String]?)
}

struct Step {
    let id: String
    let type: StepType
}
