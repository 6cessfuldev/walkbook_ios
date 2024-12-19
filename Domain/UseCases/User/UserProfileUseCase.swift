import Foundation

protocol UserProfileUseCaseProtocol {
    func getUserProfileFromNetwork(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultUserProfileUseCase: UserProfileUseCaseProtocol {
    private let userProfileRepository: UserProfileRepository
    
    init(userProfileRepository: UserProfileRepository) {
        self.userProfileRepository = userProfileRepository
    }

    func getUserProfileFromNetwork(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        userProfileRepository.getUserProfile(byId: id, completion: completion)
    }

    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        userProfileRepository.updateUserProfile(userProfile, completion: completion)
    }
}
