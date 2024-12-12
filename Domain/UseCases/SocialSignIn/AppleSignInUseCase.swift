import Foundation

protocol AppleSignInUseCaseProtocol {
    func execute(
        nonce: String,
        completion: @escaping (Result<UserProfile, Error>) -> Void
    )
}

class AppleSignInUseCase: AppleSignInUseCaseProtocol {
    
    private let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository) {
        self.repository = repository
    }
    
    func execute(nonce: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        return repository.signInWithApple(nonce: nonce, completion: completion)
    }
}
