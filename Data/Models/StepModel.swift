import FirebaseFirestore

struct StepModel: Codable {
    let id: String?
    let type: String
    let content: String?
    let location: GeoPoint?
    let radius: Double?
    let correctAnswer: String?
    let options: [String]?
    let createdAt: Timestamp?
    let updatedAt: Timestamp?
    
    init(
        id: String?,
        type: String,
        content: String? = nil,
        location: GeoPoint? = nil,
        radius: Double? = nil,
        correctAnswer: String? = nil,
        options: [String]? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.location = location
        self.radius = radius
        self.correctAnswer = correctAnswer
        self.options = options
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func copy(
            id: String? = nil,
            type: String? = nil,
            content: String? = nil,
            location: GeoPoint? = nil,
            radius: Double? = nil,
            correctAnswer: String? = nil,
            options: [String]? = nil,
            createdAt: Timestamp? = nil,
            updatedAt: Timestamp? = nil
        ) -> StepModel {
            return StepModel(
                id: id ?? self.id,
                type: type ?? self.type,
                content: content ?? self.content,
                location: location ?? self.location,
                radius: radius ?? self.radius,
                correctAnswer: correctAnswer ?? self.correctAnswer,
                options: options ?? self.options,
                createdAt: createdAt ?? self.createdAt,
                updatedAt: updatedAt ?? self.updatedAt
            )
        }
}
