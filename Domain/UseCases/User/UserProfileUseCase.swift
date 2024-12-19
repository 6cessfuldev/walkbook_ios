import Foundation

protocol UserProfileUseCaseProtocol {
    func getUserProfile(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void)
    func getCurrentUserProfile() -> UserProfile?
    func saveCurrentUserProfile(_ profile: UserProfile)
    func clearCurrentUserProfile()
}

class DefaultUserProfileUseCase: UserProfileUseCaseProtocol {
    private let userProfileRepository: UserProfileRepository
    private let localStorageRepository: LocalStorageRepository
    
    init(userProfileRepository: UserProfileRepository, localStorageRepository: LocalStorageRepository) {
        self.userProfileRepository = userProfileRepository
        self.localStorageRepository = localStorageRepository
    }

    func getUserProfile(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        userProfileRepository.getUserProfile(byId: id) { [weak self] result in
            switch result {
            case .success(let userProfile):
                self?.saveCurrentUserProfile(userProfile)
                completion(.success(userProfile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        userProfileRepository.updateUserProfile(userProfile) { [weak self] result in
            switch result {
            case .success:
                self?.saveCurrentUserProfile(userProfile)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCurrentUserProfile() -> UserProfile? {
        return localStorageRepository.getUserProfile()
    }

    func saveCurrentUserProfile(_ profile: UserProfile) {
        localStorageRepository.saveUserProfile(profile)
    }
    
    func clearCurrentUserProfile() {
        localStorageRepository.removeUserProfile()
    }
}
