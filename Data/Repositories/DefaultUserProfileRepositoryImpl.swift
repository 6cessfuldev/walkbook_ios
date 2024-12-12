import FirebaseFirestore

class DefaultUserProfileRepositoryImpl: UserProfileRepository {
    
    private let userProfileDataSource: UserProfileRemoteDataSource
    
    init(userProfileDataSource: UserProfileRemoteDataSource) {
        self.userProfileDataSource = userProfileDataSource
    }
    
    func getUserProfile(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        self.userProfileDataSource.getUserProfile(byId: id) { result in
            switch result {
            case .success(let model):
                let entity = UserProfileMapper.toEntity(model)
                completion(.success(entity))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        self.userProfileDataSource.updateUserProfile(UserProfileMapper.toModel(userProfile), completion: completion)
    }
}
