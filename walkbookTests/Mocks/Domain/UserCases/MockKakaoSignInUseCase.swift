import UIKit
@testable import walkbook

class MockKakaoSignInUseCase: KakaoSignInUseCaseProtocol {
    
    var shouldReturnError = false
    var mockEmail = "test@example.com"
    
    func execute(completion: @escaping (Result<String, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else {
            completion(.success(mockEmail))
        }
    }
}
