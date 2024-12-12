import Foundation

protocol NaverSignInUseCaseProtocol {
    func execute(
        completion: @escaping (Result<UserProfile, Error>) -> Void
    )
}

class NaverSignInUseCase: NaverSignInUseCaseProtocol {
    private let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        return repository.signInWithNaver(completion: completion)
    }
}
