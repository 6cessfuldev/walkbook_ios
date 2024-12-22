import FirebaseFirestore

struct StepModel: Codable {
    let id: String?
    let type: String
    let content: String?
    let location: GeoPoint?
    let radius: Double?
    let correctAnswer: String?
    let options: [String]?
    
    init(id: String?, type: String, content: String?, location: GeoPoint?, radius: Double?, correctAnswer: String?, options: [String]?) {
        self.id = id
        self.type = type
        self.content = content
        self.location = location
        self.radius = radius
        self.correctAnswer = correctAnswer
        self.options = options
    }
    
    func copy(
            id: String? = nil,
            type: String? = nil,
            content: String? = nil,
            location: GeoPoint? = nil,
            radius: Double? = nil,
            correctAnswer: String? = nil,
            options: [String]? = nil
        ) -> StepModel {
            return StepModel(
                id: id ?? self.id,
                type: type ?? self.type,
                content: content ?? self.content,
                location: location ?? self.location,
                radius: radius ?? self.radius,
                correctAnswer: correctAnswer ?? self.correctAnswer,
                options: options ?? self.options
            )
        }
}
