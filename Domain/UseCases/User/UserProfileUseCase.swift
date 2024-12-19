import Foundation

protocol UserProfileUseCaseProtocol {
    func getUserProfileFromNetwork(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func getUserProfileFromSession() -> Result<UserProfile, Error>
    func getUserIDFromSession() -> Result<String, Error>
    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void)
}

class DefaultUserProfileUseCase: UserProfileUseCaseProtocol {
    private let userProfileRepository: UserProfileRepository
    private let sessionRepository: SessionRepository
    
    init(userProfileRepository: UserProfileRepository, sessionRepository: SessionRepository) {
        self.userProfileRepository = userProfileRepository
        self.sessionRepository = sessionRepository
    }

    func getUserProfileFromNetwork(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        self.userProfileRepository.getUserProfile(byId: id, completion: completion)
    }
    
    func getUserProfileFromSession() -> Result<UserProfile, Error> {
        self.sessionRepository.getUserProfile()
    }
    
    func getUserIDFromSession() -> Result<String, Error> {
        self.sessionRepository.getUserProfile().map { $0.id }
    }

    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        userProfileRepository.updateUserProfile(userProfile, completion: completion)
    }
}
