import Foundation

protocol AppleSignInUseCase {
    func execute(
        nonce: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

class DefaultAppleSignInUseCase: AppleSignInUseCase {
    
    private let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository) {
        self.repository = repository
    }
    
    func execute(nonce: String, completion: @escaping (Result<String, Error>) -> Void) {
        return repository.signInWithApple(nonce: nonce, completion: completion)
    }
}
