import FirebaseFirestore

protocol StoryRemoteDataSource {
    func add(story: StoryModel, completion: @escaping (Result<StoryModel, Error>) -> Void)
    func fetchAll(completion: @escaping (Result<[StoryModel], Error>) -> Void)
    func fetchByAuthorId(by id: String, completion: @escaping (Result<[StoryModel], Error>) -> Void)
    func update(story: StoryModel, with id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func updateRootChapter(storyId: String, chapterId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(by id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirestoreStoryRemoteDataSourceImpl: StoryRemoteDataSource {
    private let db = Firestore.firestore()
    
    func add(story: StoryModel, completion: @escaping (Result<StoryModel, Error>) -> Void) {
        do {
            let data = try story.toDictionary()
            
            let documentRef = db.collection("stories").document()
            var updatedData = data
            updatedData["id"] = documentRef.documentID
            
            documentRef.setData(updatedData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let createdStory = story.copy(id: documentRef.documentID)
                    
                    completion(.success(createdStory))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func fetchAll(completion: @escaping (Result<[StoryModel], Error>) -> Void) {
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
    
    func fetchByAuthorId(by id: String, completion: @escaping (Result<[StoryModel], Error>) -> Void) {
        db.collection("stories")
            .whereField("authorId", isEqualTo: id)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let stories: [StoryModel] = documents.compactMap { document in
                    try? document.data(as: StoryModel.self)
                }
                
                completion(.success(stories))
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
    
    func updateRootChapter(storyId: String, chapterId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let documentRef = db.collection(FirestoreCollections.stories).document(storyId)
        
        documentRef.updateData(["rootChapter": chapterId]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
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
