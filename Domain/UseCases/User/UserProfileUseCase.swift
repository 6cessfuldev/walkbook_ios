import Foundation

protocol UserProfileUseCaseProtocol {
    func getUserProfile(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultUserProfileUseCase: UserProfileUseCaseProtocol {
    private let repository: UserProfileRepository
    
    init(repository: UserProfileRepository) {
            self.repository = repository
        }

        func getUserProfile(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
            repository.getUserProfile(byId: id, completion: completion)
        }

        func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
            repository.updateUserProfile(userProfile, completion: completion)
        }
}
