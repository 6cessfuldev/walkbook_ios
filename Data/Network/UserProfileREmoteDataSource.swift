import FirebaseFirestore

protocol UserProfileRemoteDataSource {
    func getUserProfile(byId id: String, completion: @escaping (Result<UserProfileModel, Error>) -> Void)
    func updateUserProfile(_ userProfile: UserProfileModel, completion: @escaping (Result<Void, Error>) -> Void)
}

class FirestoreUserProfileRemoteDataSourceImpl: UserProfileRemoteDataSource {
    
    private let db = Firestore.firestore()
    private let collectionName = "user_profiles"
    
    func getUserProfile(byId id: String, completion: @escaping (Result<UserProfileModel, Error>) -> Void) {
        db.collection(collectionName).document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                guard var data = document.data(),
                      let userProfile = UserProfileModel(dictionary: data) else {
                    completion(.failure(NSError(domain: "DecodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode UserProfile"])))
                    return
                }
                completion(.success(userProfile))
            } else {
                completion(.failure(NSError(domain: "NotFoundError", code: 404, userInfo: [NSLocalizedDescriptionKey: "UserProfile not found"])))
            }
        }
    }
    
    func updateUserProfile(_ userProfile: UserProfileModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try userProfile.toDictionary()
            db.collection(collectionName).document(userProfile.id).setData(data) { error in
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

