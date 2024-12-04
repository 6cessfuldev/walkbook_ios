struct StoryModel: Codable {
    var id: String?
    var title: String
    var author: String
    var imageUrl: String
    var description: String

    init(id: String? = nil, title: String, author: String, imageUrl: String, description: String) {
        self.id = id
        self.title = title
        self.author = author
        self.imageUrl = imageUrl
        self.description = description
    }
}
