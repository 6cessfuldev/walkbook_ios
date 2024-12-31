import FirebaseFirestore
import CoreLocation

protocol StepRemoteDataSource {
    func add(step: StepModel, chapterId: String, storyId: String, completion: @escaping (Result<StepModel, Error>) -> Void)
    func fetchByChapterId(by chapterId: String, completion: @escaping (Result<[StepModel], Error>) -> Void)
    func update(step: StepModel, chapterId: String, storyId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirestoreStepRemoteDataSourceImpl: StepRemoteDataSource {
    
    private let db = Firestore.firestore()
    private let chapterRemoteDataSource: ChapterRemoteDataSource
    
    init(chapterRemoteDataSource: ChapterRemoteDataSource) {
        self.chapterRemoteDataSource = chapterRemoteDataSource
    }
    
    func add(step: StepModel, chapterId: String, storyId: String, completion: @escaping (Result<StepModel, Error>) -> Void) {
        
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
                self.chapterRemoteDataSource.fetchByStoryId(by: storyId) { r in
                    switch r {
                    case .success(let chapters):
                        self.updateChapterAndStoryInTransaction(step: step, chapterId: chapterId, storyId: storyId, chapters: chapters)
                    case .failure(let error):
                        print("fetchChapterByStoryId failed: \(error.localizedDescription)")
                    }
                }
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
    
    func update(step: StepModel, chapterId: String, storyId: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
                    self.chapterRemoteDataSource.fetchByStoryId(by: storyId) { r in
                        switch r {
                        case .success(let chapters):
                            self.updateChapterAndStoryInTransaction(step: step, chapterId: chapterId, storyId: storyId, chapters: chapters)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
        
        
    }
    
    private func updateChapterAndStoryInTransaction(
        step: StepModel,
        chapterId: String,
        storyId: String,
        chapters: [ChapterModel]
    ) {
        guard let stepId = step.id else {
            print("updateChapterAndStoryInTransaction : Not found step id")
            return
        }
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let chapterRef = self.db.collection(FirestoreCollections.chapters).document(chapterId)
            let storyRef = self.db.collection(FirestoreCollections.stories).document(storyId)
            
            // Chapter 업데이트
            let chapterSnapshot: DocumentSnapshot
            do {
                chapterSnapshot = try transaction.getDocument(chapterRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            guard var chapterData = chapterSnapshot.data(),
                  var stepIds = chapterData["steps"] as? [String] else {
                errorPointer?.pointee = NSError(domain: "TransactionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Chapter data missing or invalid"])
                return nil
            }
            
            let steps = self.fetchStepsInTransaction(stepIds: stepIds, transaction: transaction)
            guard let steps = steps else {
                errorPointer?.pointee = NSError(domain: "TransactionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Steps data missing or invalid"])
                return nil
            }
            
            let totalChapterDistance = self.calculateTotalDistance(for: steps)
            let totalChapterDuration = self.convertDistanceToDuration(distance: totalChapterDistance)
            chapterData["duration"] = totalChapterDuration
            transaction.updateData(chapterData, forDocument: chapterRef)

            let updatedChapters = self.updateChaptersDurationById(chapterId: chapterId, duration: totalChapterDuration, chapters: chapters)
            
            // 최대 거리를 계산하기 위해 nestedChapter로 변환
            let rootNestedChapter = ChapterTreeBuilder.buildTree(flatChapters: updatedChapters)
            guard let rootNestedChapter = rootNestedChapter else {
                errorPointer?.pointee = NSError(domain: "BuildTreeError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not Found Root NestedChapter"])
                return nil
            }
            
            // Story의 Chapter 트리를 참고하여 최대 소요 시간 계산
            let totalStoryDuration = self.caculateStoryMaxDuration(nestedChapter: rootNestedChapter)
            
            // Story Duration 업데이트
            let storySnapshot: DocumentSnapshot
            do {
                storySnapshot = try transaction.getDocument(storyRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            guard var storyData = storySnapshot.data() else {
                errorPointer?.pointee = NSError(domain: "TransactionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Story data missing or invalid"])
                return nil
            }
            
            storyData["duration"] = totalStoryDuration
            transaction.updateData(storyData, forDocument: storyRef)
            
            return nil
        }) { (result, error) in
            if let error = error {
                print("Transaction failed: \(error.localizedDescription)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    private func updateChaptersDurationById(chapterId: String, duration: Int, chapters: [ChapterModel]) -> [ChapterModel] {
        return chapters.map { chapter in
            if chapter.id == chapterId {
                let updatedChapter = chapter.copy(duration: duration)
                return updatedChapter
            }
            return chapter
        }
    }
    
    private func fetchStepsInTransaction(stepIds: [String], transaction: Transaction) -> [StepModel]? {
        var stepModels: [StepModel] = []
        
        for stepId in stepIds {
            let stepRef = db.collection(FirestoreCollections.steps).document(stepId)
            
            do {
                let stepSnapshot = try transaction.getDocument(stepRef)
                let step = try stepSnapshot.data(as: StepModel.self)
                stepModels.append(step)
            } catch {
                print("Failed to fetch StepModel for ID: \(stepId), Error: \(error)")
                return nil
            }
        }
        
        return stepModels
    }
    
    private func caculateStoryMaxDuration(nestedChapter: NestedChapter) -> Int {
        var maxDuration = 0
        var queue: [(node: NestedChapter, sum: Int)] = [(nestedChapter, nestedChapter.duration ?? 0)]
        
        while !queue.isEmpty {
            let (currentNode, currentSum) = queue.removeFirst()
            
            if currentNode.childChapters.isEmpty {
                maxDuration = max(maxDuration, currentSum)
            }
            
            for child in currentNode.childChapters {
                let childDuration = currentSum + (child.duration ?? 0)
                queue.append((child, childDuration))
            }
        }
        
        return maxDuration
    }
    
    private func calculateTotalDistance(for steps: [StepModel]) -> Double {
        var totalDistance: Double = 0.0
        var previousLocation: GeoPoint? = nil
        
        for step in steps {
            guard let currentLocation = step.location else {
                continue
            }
            
            let currentCLLocation = GeoPoint(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            
            if let prevLocation = previousLocation {
                let distance = calculateDistanceBetweenGeoPoints(prevLocation, currentLocation)
                totalDistance += distance
            }
            
            previousLocation = currentCLLocation
        }
        
        return totalDistance
    }
    
    private func convertDistanceToDuration(distance: Double) -> Int {
        // 5km/h
        let averageSpeedMetersPerMinute = 83.33
        return Int(distance / averageSpeedMetersPerMinute)
    }
    
    private func calculateDistanceBetweenGeoPoints(_ point1: GeoPoint, _ point2: GeoPoint) -> Double {
        let location1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
        let location2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
        
        return location1.distance(from: location2) // 거리(m) 반환
    }
}
