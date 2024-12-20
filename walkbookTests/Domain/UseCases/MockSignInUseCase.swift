import Foundation
import RxSwift
import RxCocoa

@testable import walkbook

class MockSignInUseCase: SignInUseCaseProtocol {
    
    // 로그인을 시뮬레이션하기 위한 변수들
    var isExecuteCalled = false
    var expectedProvider: AuthProvider?
    var mockResult: Result<UserProfile, Error> = .failure(NSError(domain: "TestError", code: -1, userInfo: nil))
    
    func execute(provider: AuthProvider, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        isExecuteCalled = true
        expectedProvider = provider
        completion(mockResult)
    }
}
