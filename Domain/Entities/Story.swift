import Foundation

struct Book: Codable {
    var title: String
    var author: String
    var imageUrl: String
    var description: String
    
    var id: String?
    
    init(title: String, author: String, imageUrl: String, description: String, id: String? = nil) {
        self.title = title
        self.author = author
        self.imageUrl = imageUrl
        self.description = description
        self.id = id
    }
    
    init?(dictionary: [String: Any]) {
        guard let title = dictionary["title"] as? String,
              let author = dictionary["author"] as? String,
              let imageUrl = dictionary["imageUrl"] as? String,
              let description = dictionary["description"] as? String else { return nil }
        
        self.title = title
        self.author = author
        self.imageUrl = imageUrl
        self.description = description
        self.id = dictionary["id"] as? String
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "author": author,
            "imageUrl": imageUrl,
            "description": description,
            "id": id ?? ""
        ]
    }
}
