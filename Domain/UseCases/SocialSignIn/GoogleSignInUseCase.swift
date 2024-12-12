import UIKit

protocol GoogleSignInUseCaseProtocol {
    func execute(
        presenting viewController: UIViewController,
        completion: @escaping (Result<UserProfile, Error>) -> Void
    )
}

class GoogleSignInUseCase: GoogleSignInUseCaseProtocol {
    
    private let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository) {
        self.repository = repository
    }
    
    func execute(presenting viewController: UIViewController, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        return repository.signInWithGoogle(presenting: viewController, completion: completion)
    }
}
