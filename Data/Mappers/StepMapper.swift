import CoreLocation
import FirebaseFirestoreInternal
import Foundation

class StepMapper {
    
    static func toEntity(_ model: StepModel) -> Step {
        switch model.type {
        case "text":
            return Step(
                id: model.id,
                type: .text(model.content ?? ""),
                location: model.location?.toCoordinate(),
                createdAt: model.createdAt?.dateValue(),
                updatedAt: model.updatedAt?.dateValue())
        case "music":
            return Step(
                id: model.id,
                type: .music(model.content ?? ""),
                location: model.location?.toCoordinate(),
                createdAt: model.createdAt?.dateValue(),
                updatedAt: model.updatedAt?.dateValue())
        case "video":
            return Step(
                id: model.id,
                type: .video(model.content ?? ""),
                location: model.location?.toCoordinate(),
                createdAt: model.createdAt?.dateValue(),
                updatedAt: model.updatedAt?.dateValue())
        case "image":
            return Step(
                id: model.id,
                type: .image(model.content ?? ""),
                location: model.location?.toCoordinate(), 
                createdAt: model.createdAt?.dateValue(),
                updatedAt: model.updatedAt?.dateValue())
        case "question":
            return Step(
                id: model.id,
                type: .question(correctAnswer: model.correctAnswer ?? "",
                                options: model.options),
                location: model.location?.toCoordinate(), 
                createdAt: model.createdAt?.dateValue(),
                updatedAt: model.updatedAt?.dateValue())
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
                location: step.location?.toGeoPoint(),
                radius: nil,
                correctAnswer: nil,
                options: nil,
                createdAt: step.createdAt != nil ? Timestamp(date: step.createdAt!) : nil,
                updatedAt: step.updatedAt != nil ? Timestamp(date: step.updatedAt!) : nil
            )
        case .music(let url):
            return StepModel(
                id: step.id,
                type: "music",
                content: url,
                location: step.location?.toGeoPoint(),
                radius: nil,
                correctAnswer: nil,
                options: nil,
                createdAt: step.createdAt != nil ? Timestamp(date: step.createdAt!) : nil,
                updatedAt: step.updatedAt != nil ? Timestamp(date: step.updatedAt!) : nil
            )
        case .video(let url):
            return StepModel(
                id: step.id,
                type: "video",
                content: url,
                location: step.location?.toGeoPoint(),
                radius: nil,
                correctAnswer: nil,
                options: nil,
                createdAt: step.createdAt != nil ? Timestamp(date: step.createdAt!) : nil,
                updatedAt: step.updatedAt != nil ? Timestamp(date: step.updatedAt!) : nil
            )
        case .image(let url):
            return StepModel(
                id: step.id,
                type: "image",
                content: url,
                location: step.location?.toGeoPoint(),
                radius: nil,
                correctAnswer: nil,
                options: nil,
                createdAt: step.createdAt != nil ? Timestamp(date: step.createdAt!) : nil,
                updatedAt: step.updatedAt != nil ? Timestamp(date: step.updatedAt!) : nil
            )
        case .question(let correctAnswer, let options):
            return StepModel(
                id: step.id,
                type: "question",
                content: nil,
                location: step.location?.toGeoPoint(),
                radius: nil,
                correctAnswer: correctAnswer,
                options: options,
                createdAt: step.createdAt != nil ? Timestamp(date: step.createdAt!) : nil,
                updatedAt: step.updatedAt != nil ? Timestamp(date: step.updatedAt!) : nil
            )
        }
    }
}
