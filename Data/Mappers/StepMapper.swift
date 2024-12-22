import CoreLocation
import Foundation

class StepMapper {
    
    static func toEntity(_ model: StepModel) -> Step {
        switch model.type {
        case "text":
            return Step(id: model.id, type: .text(model.content ?? ""))
        case "music":
            return Step(id: model.id, type: .music(model.content ?? ""))
        case "video":
            return Step(id: model.id, type: .video(model.content ?? ""))
        case "image":
            return Step(id: model.id, type: .image(model.content ?? ""))
        case "mission":
            return Step(id: model.id, type: .mission(location: model.location?.toCoordinate(), radius: model.radius ?? 0.0))
        case "question":
            return Step(id: model.id, type: .question(correctAnswer: model.correctAnswer ?? "", options: model.options))
        default:
            fatalError("Unsupported Step type: \(model.type)")
        }
    }
    
    static func toDataModel(_ step: Step) -> StepModel {
        switch step.type {
        case .text(let content):
            return StepModel(
                id: step.id,
                type: "text",
                content: content,
                location: nil,
                radius: nil,
                correctAnswer: nil,
                options: nil
            )
        case .music(let url):
            return StepModel(
                id: step.id,
                type: "music",
                content: url,
                location: nil,
                radius: nil,
                correctAnswer: nil,
                options: nil
            )
        case .video(let url):
            return StepModel(
                id: step.id,
                type: "video",
                content: url,
                location: nil,
                radius: nil,
                correctAnswer: nil,
                options: nil
            )
        case .image(let url):
            return StepModel(
                id: step.id,
                type: "image",
                content: url,
                location: nil,
                radius: nil,
                correctAnswer: nil,
                options: nil
            )
        case .mission(let location, let radius):
            return StepModel(
                id: step.id,
                type: "mission",
                content: nil,
                location: location?.toGeoPoint(),
                radius: radius,
                correctAnswer: nil,
                options: nil
            )
        case .question(let correctAnswer, let options):
            return StepModel(
                id: step.id,
                type: "question",
                content: nil,
                location: nil,
                radius: nil,
                correctAnswer: correctAnswer,
                options: options
            )
        }
    }
}
