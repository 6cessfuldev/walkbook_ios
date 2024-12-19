import Foundation
@testable import walkbook

class MockAppleSignInUseCase: AppleSignInUseCaseProtocol {
    var shouldReturnError = false
    var mockEmail = "test@example.com"
    
    func execute(nonce: String, completion: @escaping (Result<walkbook.UserProfile, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else {
            completion(.success(UserProfile(id: "1", provider: "apple", name: nil, nickname: nil, imageUrl: nil)))
        }
    }
}
