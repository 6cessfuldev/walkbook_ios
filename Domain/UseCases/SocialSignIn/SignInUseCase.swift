import UIKit

enum AuthProvider {
    case google(presenting: UIViewController)
    case apple(nonce: String)
    case kakao
    case naver
}

protocol SignInUseCaseProtocol {
    func execute(
        provider: AuthProvider,
        completion: @escaping (Result<UserProfile, Error>) -> Void
    )
}

class SignInUseCase: SignInUseCaseProtocol {
    
    private let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository) {
        self.repository = repository
    }
    
    func execute(provider: AuthProvider, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        switch provider {
        case .google(let presenting):
            repository.signInWithGoogle(presenting: presenting, completion: completion)
            
        case .apple(let nonce):
            repository.signInWithApple(nonce: nonce, completion: completion)
            
        case .kakao:
            repository.signInWithKakao(completion: completion)
            
        case .naver:
            repository.signInWithNaver(completion: completion)
        }
    }
}
