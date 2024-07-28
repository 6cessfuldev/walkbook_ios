import UIKit
@testable import walkbook

class MockGoogleSignInUseCase: GoogleSignInUseCaseProtocol {
    
    var shouldReturnError = false
    var mockEmail = "test@example.com"
    
    func execute(presenting viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else {
            completion(.success(mockEmail))
        }
    }
}
