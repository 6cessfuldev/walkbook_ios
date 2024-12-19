import UIKit
@testable import walkbook

class MockNaverSignInUseCase: NaverSignInUseCaseProtocol {
    
    var shouldReturnError = false
    var mockEmail = "test@example.com"
    
    func execute(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "TestError", code: 1, userInfo: nil)))
        } else {
            completion(.success(UserProfile(id: "1", provider: "Naver", name: mockEmail, nickname: nil, imageUrl: nil)))
        }
    }
}
