import FirebaseFirestore

protocol StoryRemoteDataSource {
    func add(story: StoryModel, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchAll(completion: @escaping (Result<[StoryModel], Error>) -> Void)
    func update(story: StoryModel, with id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(by id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

enum FirestoreCollections {
    static let stories = "stories"
}

class FirestoreStoryRemoteDataSourceImpl: StoryRemoteDataSource {
//    private let db = Firestore.firestore()
    
    func add(story: StoryModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let settings = FirestoreSettings()
            settings.isPersistenceEnabled = false
            Firestore.firestore().settings = settings
            
//            var data = try story.toDictionary()
            let data: [String: Any] = [
                "title": "Test Story",
                "author": "John Doe",
                "imageUrl": "https://example.com/image.jpg",
                "description": "Sample description"
            ]
            let db = Firestore.firestore()
            db.collection("story").addDocument(data: data) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Write successful!")
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func fetchAll(completion: @escaping (Result<[StoryModel], Error>) -> Void) {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        db.collection("stories").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let entities: [StoryModel] = snapshot?.documents.compactMap { document in
                    var data = document.data()
                    data["id"] = document.documentID
                    return StoryModel(dictionary: data)
                } ?? []
                completion(.success(entities))
            }
        }
    }

    func update(story: StoryModel, with id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let db = Firestore.firestore()
            let data = try story.toDictionary()
            db.collection(FirestoreCollections.stories).document(id).setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func delete(by id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection(FirestoreCollections.stories).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
    }
}

extension Decodable {
    init?(dictionary: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed),
              let decoded = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        self = decoded
    }
}
