import CoreLocation

enum StepType {
    case text(String)
    case music(String)
    case video(String)
    case image(String)
    case mission(location: CLLocationCoordinate2D?, radius: Double)
    case question(correctAnswer: String, options: [String]?)
    
    var stringValue: String {
        switch self {
        case .text: return "text"
        case .music: return "music"
        case .video: return "video"
        case .image: return "image"
        case .mission: return "mission"
        case .question: return "question"
        }
    }
}

struct Step {
    let id: String?
    var type: StepType
}
