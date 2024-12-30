import Foundation
import CoreLocation
import FirebaseFirestore

struct ChapterMapper {
    
    static func toModel(_ chapter: Chapter) -> ChapterModel {
        return ChapterModel(
            id: chapter.id,
            storyId: chapter.storyId,
            title: chapter.title,
            imageUrl: chapter.imageUrl,
            description: chapter.description,
            location: chapter.location != nil ? GeoPoint(latitude: chapter.location!.latitude, longitude: chapter.location!.longitude) : nil,
            radius: chapter.radius,
            steps: chapter.steps,
            childChapters: chapter.childChapters,
            duration: chapter.duration,
            createdAt: chapter.createdAt != nil ? Timestamp(date: chapter.createdAt!) : nil,
            updatedAt: chapter.updatedAt != nil ? Timestamp(date: chapter.updatedAt!) : nil
        )
    }
    
    static func toEntity(_ model: ChapterModel) -> Chapter {
        return Chapter(
            id: model.id,
            storyId: model.storyId,
            title: model.title,
            imageUrl: model.imageUrl,
            description: model.description,
            location: model.location != nil ? CLLocationCoordinate2D(latitude: model.location!.latitude, longitude: model.location!.longitude) : nil,
            radius: model.radius,
            steps: model.steps,
            childChapters: model.childChapters,
            duration: model.duration,
            createdAt: model.createdAt?.dateValue(),
            updatedAt: model.updatedAt?.dateValue()
        )
    }
}
