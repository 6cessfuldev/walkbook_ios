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
    
    private let authRepository: AuthenticationRepository
    private let sessionRepository: SessionRepository
    
    init(authRepository: AuthenticationRepository, sessionRepository: SessionRepository) {
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
    }
    
    func execute(provider: AuthProvider, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        signInNetwork(provider: provider) { result in
            switch result {
            case .success(let userProfile):
                self.saveSession(profile: userProfile) { sessionResult in
                    if case .failure(let error) = sessionResult {
                        completion(.failure(error))
                    } else {
                        completion(.success(userProfile))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signInNetwork(provider: AuthProvider, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        switch provider {
        case .google(let presenting):
            authRepository.signInWithGoogle(presenting: presenting, completion: completion)
            
        case .apple(let nonce):
            authRepository.signInWithApple(nonce: nonce, completion: completion)
            
        case .kakao:
            authRepository.signInWithKakao(completion: completion)
            
        case .naver:
            authRepository.signInWithNaver(completion: completion)
        }
    }
    
    func saveSession(profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        sessionRepository.saveUserProfile(profile, completion: completion)
    }
}
