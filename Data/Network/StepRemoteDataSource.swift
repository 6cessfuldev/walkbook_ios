import FirebaseFirestore

protocol StepRemoteDataSource {
    func add(_ step: StepModel, to chapterId: String, completion: @escaping (Result<StepModel, Error>) -> Void)
    
    func fetchByChapterId(by chapterId: String, completion: @escaping (Result<[StepModel], Error>) -> Void)
    
    func update(_ step: StepModel, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirestoreStepRemoteDataSourceImpl: StepRemoteDataSource {
    private let db = Firestore.firestore()
    
    func add(_ step: StepModel, to chapterId: String, completion: @escaping (Result<StepModel, Error>) -> Void) {
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let chapterRef = self.db.collection(FirestoreCollections.chapters).document(chapterId)
            let stepRef = self.db.collection(FirestoreCollections.steps).document()
            
            let chapterSnapshot: DocumentSnapshot
            do {
                chapterSnapshot = try transaction.getDocument(chapterRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            guard var chapterData = chapterSnapshot.data() else {
                errorPointer?.pointee = NSError(
                    domain: "FirestoreTransactionError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Parent chapter not found"]
                )
                return nil
            }
            
            let createdStep = step.copy(id: stepRef.documentID)
            
            do {
                let stepData = try createdStep.toDictionary()
                transaction.setData(stepData, forDocument: stepRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            var steps = chapterData["steps"] as? [String] ?? []
            steps.append(stepRef.documentID)
            chapterData["steps"] = steps
            
            transaction.updateData(chapterData, forDocument: chapterRef)
            
            return createdStep
        }) { (result, error) in
            if let error = error {
                completion(.failure(error))
            } else if let createdStep = result as? StepModel {
                completion(.success(createdStep))
            } else {
                completion(.failure(NSError(
                    domain: "FirestoreTransactionError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]
                )))
            }
        }
    }
    
    func fetchByChapterId(by chapterId: String, completion: @escaping (Result<[StepModel], Error>) -> Void) {
        let chapterRef = db.collection(FirestoreCollections.chapters).document(chapterId)
        
        chapterRef.getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let stepIds = data["steps"] as? [String],
                  !stepIds.isEmpty else {
                completion(.success([]))
                return
            }
            
            self.db.collection(FirestoreCollections.steps)
                .whereField(FieldPath.documentID(), in: stepIds)
                .getDocuments { (stepSnapshot, stepError) in
                    if let stepError = stepError {
                        completion(.failure(stepError))
                        return
                    }
                    
                    let steps: [StepModel] = stepSnapshot?.documents.compactMap { document in
                        do {
                            var step = try document.data(as: StepModel.self)
                            step = step.copy(id: document.documentID)
                            return step
                        } catch {
                            print("Error decoding StepModel: \(error)")
                            return nil
                        }
                    } ?? []
                    
                    completion(.success(steps))
                }
        }
    }
    
    func update(_ step: StepModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let stepId = step.id else {
            completion(.failure(NSError(
                domain: "FirestoreUpdateError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Step ID is required for update."]
            )))
            return
        }
        
        let stepRef = db.collection(FirestoreCollections.steps).document(stepId)
        
        do {
            let stepData = try step.toDictionary()
            stepRef.setData(stepData, merge: true) { error in
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
}
