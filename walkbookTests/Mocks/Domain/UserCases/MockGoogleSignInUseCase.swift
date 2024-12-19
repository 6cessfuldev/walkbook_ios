import UIKit
@testable import walkbook

class MockGoogleSignInUseCase: GoogleSignInUseCaseProtocol {
    var shouldReturnError = false
    var mockEmail = "test@example.com"
    
    func execute(presenting viewController: UIViewController, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else {
            completion(.success(UserProfile(id: "1", provider: "Google", name: "mockEmail", nickname: nil, imageUrl: nil)))
        }
    }
}
