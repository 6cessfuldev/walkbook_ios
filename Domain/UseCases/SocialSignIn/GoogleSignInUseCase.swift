import UIKit

protocol GoogleSignInUseCaseProtocol {
    func execute(
        presenting viewController: UIViewController,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

class GoogleSignInUseCase: GoogleSignInUseCaseProtocol {
    
    private let repository: AuthenticationRepository
    
    init(repository: AuthenticationRepository) {
        self.repository = repository
    }
    
    func execute(presenting viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        return repository.signInWithGoogle(presenting: viewController, completion: completion)
    }
}
