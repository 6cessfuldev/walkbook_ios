import Foundation
@testable import walkbook

class MockAppleSignInUseCase: AppleSignInUseCase {
    var shouldReturnError = false
    var mockEmail = "test@example.com"
    
    func execute(nonce: String, completion: @escaping (Result<String, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else {
            completion(.success(mockEmail))
        }
    }
}
