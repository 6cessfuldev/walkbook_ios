import FirebaseFirestore

protocol ChapterRemoteDataSource {
    func add(chapter: ChapterModel, completion: @escaping (Result<ChapterModel, Error>) -> Void)
    func addChildChapter(_ child: ChapterModel, to parentChapterId: String, completion: @escaping (Result<ChapterModel, Error>) -> Void)
    func fetchByStoryId(by id: String, completion: @escaping (Result<[ChapterModel], Error>) -> Void)
    func update(chapter: ChapterModel, with id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(by id: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirestoreChapterRemoteDataSourceImpl: ChapterRemoteDataSource {
    private let db = Firestore.firestore()
    
    func add(chapter: ChapterModel, completion: @escaping (Result<ChapterModel, Error>) -> Void) {
        do {
            let data = try chapter.toDictionary()
            
            let documentRef = db.collection(FirestoreCollections.chapters).document()
            var updatedData = data
            updatedData["id"] = documentRef.documentID
            
            documentRef.setData(updatedData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    var createdChapter = chapter
                    createdChapter.id = documentRef.documentID
                    
                    completion(.success(createdChapter))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func addChildChapter( _ child: ChapterModel, to parentChapterId: String, completion: @escaping (Result<ChapterModel, Error>) -> Void ) {
        var createdChildChapter = child
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let parentRef = self.db.collection(FirestoreCollections.chapters).document(parentChapterId)
            let childRef = self.db.collection(FirestoreCollections.chapters).document()
            
            let parentSnapshot: DocumentSnapshot
            do {
                parentSnapshot = try transaction.getDocument(parentRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            guard var parentData = parentSnapshot.data() else {
                errorPointer?.pointee = NSError(
                    domain: "FirestoreTransactionError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Parent chapter not found"]
                )
                return nil
            }
            
            createdChildChapter.id = childRef.documentID
            createdChildChapter.storyId = parentData["storyId"] as? String
            
            do {
                let childData = try createdChildChapter.toDictionary()
                transaction.setData(childData, forDocument: childRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            var childChapters = parentData["childChapters"] as? [String] ?? []
            childChapters.append(childRef.documentID)
            parentData["childChapters"] = childChapters
            
            transaction.updateData(parentData, forDocument: parentRef)
            
            return createdChildChapter
        }) { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else if let createdChildChapter = result as? ChapterModel {
                completion(.success(createdChildChapter))
            } else {
                completion(.failure(NSError(
                    domain: "FirestoreTransactionError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]
                )))
            }
        }
    }
    
    func fetchByStoryId(by id: String, completion: @escaping (Result<[ChapterModel], Error>) -> Void) {
        db.collection(FirestoreCollections.chapters)
            .whereField("storyId", isEqualTo: id)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let stories: [ChapterModel] = documents.compactMap { document in
                    try? document.data(as: ChapterModel.self)
                }
                
                completion(.success(stories))
            }
    }

    func update(chapter: ChapterModel, with id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let db = Firestore.firestore()
            let data = try chapter.toDictionary()
            db.collection(FirestoreCollections.chapters).document(id).setData(data) { error in
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
        db.collection(FirestoreCollections.chapters).document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
