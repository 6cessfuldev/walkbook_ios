import CoreLocation

enum StepType {
    case text(String)
    case music(String)
    case video(String)
    case image(String)
    case question(correctAnswer: String, options: [String]?)
    
    var stringValue: String {
        switch self {
        case .text: return "text"
        case .music: return "music"
        case .video: return "video"
        case .image: return "image"
        case .question: return "question"
        }
    }
}

struct Step {
    let id: String?
    var type: StepType
    let location:CLLocationCoordinate2D?
}
