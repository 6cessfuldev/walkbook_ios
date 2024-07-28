import Foundation

protocol NaverSignInUseCaseProtocol {
    func execute(
        completion: @escaping (Result<String, Error>) -> Void
    )
}

class NaverSignInUseCase: NaverSignInUseCaseProtocol {
    private let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (Result<String, Error>) -> Void) {
        return repository.signInWithNaver(completion: completion)
    }
}
