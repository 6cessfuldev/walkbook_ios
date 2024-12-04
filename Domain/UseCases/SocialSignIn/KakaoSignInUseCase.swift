import UIKit

protocol KakaoSignInUseCaseProtocol {
    func execute(
        completion: @escaping (Result<String, Error>) -> Void
    )
}

class KakaoSignInUseCase: KakaoSignInUseCaseProtocol {
    
    private let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (Result<String, Error>) -> Void) {
        return repository.signInWithKakao(completion: completion)
    }
}
