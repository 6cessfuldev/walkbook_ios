import UIKit
import XCTest
import RxSwift
import RxCocoa
@testable import walkbook

class AuthenticationViewModelTests: XCTestCase {
    
    var viewModel: AuthenticationViewModel!
    var mockSignInUseCase: MockSignInUseCase!
    var mockUserProfileViewmodel: MockUserProfileViewModel!
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockSignInUseCase = MockSignInUseCase()
        viewModel = AuthenticationViewModel(
            userProfileViewModel: MockUserProfileViewModel(), 
            signInUseCase: mockSignInUseCase)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
        mockSignInUseCase = nil
        disposeBag = nil
        super.tearDown()
    }
    
    func test_currentState_초기값() {
        XCTAssertEqual(viewModel.currentState.value, .chooseLogin)
    }
    
    func test_SignInTapped할_시_currentState가_signIn으로_변경() {
        let expectation = self.expectation(description: "signIn으로 변경")
        
        viewModel.currentState
            .skip(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, .signIn)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        viewModel.signInTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_SignUpTapped할_시_currentState가_signUp으로_변경() {
        let expectation = self.expectation(description: "signUp으로 변경")
        
        viewModel.currentState
            .skip(1)
            .subscribe(onNext: { state in
                XCTAssertEqual(state, .signUp)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        viewModel.signUpTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_GoogleSignIn_성공_시_email_값_전달받음() {
        let expectation = self.expectation(description: "email 값 전달받음")
        
        let expectedUserProfile = UserProfile(id: "123", provider: "Google", name: "Yuk",  nickname: nil, imageUrl: nil)
        mockSignInUseCase.mockResult = .success(expectedUserProfile)
        
        viewModel.userProfile
            .skip(1)
            .subscribe(onNext: { userProfile in
                if let userProfile = userProfile {
                    XCTAssertEqual(userProfile, expectedUserProfile)
                    expectation.fulfill()
                } else {
                    XCTFail("userProfile is nil")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.googleSignInTapped.onNext(UIViewController())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_GoogleSignIn_실패_시_Error_전달받음() {
        let expectation = self.expectation(description: "Error 전달받음")
        
        viewModel.error
            .subscribe(onNext: { error in
                XCTAssertNotNil(error)
                if let nsError = error as NSError? {
                    XCTAssertEqual(nsError.domain, "TestError")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected an NSError but got \(String(describing: error))")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.googleSignInTapped.onNext(UIViewController())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_KakaoSignIn_성공_시_email_값_전달받음() {
        let expectation = self.expectation(description: "email 값 전달받음")
        
        let expectedUserProfile = UserProfile(id: "123", provider: "Kakao", name: "Yuk",  nickname: nil, imageUrl: nil)
        mockSignInUseCase.mockResult = .success(expectedUserProfile)
        
        viewModel.userProfile
            .skip(1)
            .subscribe(onNext: { userProfile in
                if let userProfile = userProfile {
                    XCTAssertEqual(userProfile, expectedUserProfile)
                    expectation.fulfill()
                } else {
                    XCTFail("userProfile is nil")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.kakaoSignInTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_KakaoSignIn_실패_시_Error_전달받음() {
        let expectation = self.expectation(description: "Error 전달받음")
        
        viewModel.error
            .subscribe(onNext: { error in
                XCTAssertNotNil(error)
                if let nsError = error as NSError? {
                    XCTAssertEqual(nsError.domain, "TestError")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected an NSError but got \(String(describing: error))")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.kakaoSignInTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_NaverSignIn_성공_시_email_값_전달받음() {
        let expectation = self.expectation(description: "email 값 전달받음")
        
        let expectedUserProfile = UserProfile(id: "123", provider: "Kakao", name: "Yuk",  nickname: nil, imageUrl: nil)
        mockSignInUseCase.mockResult = .success(expectedUserProfile)
        
        viewModel.userProfile
            .skip(1)
            .subscribe(onNext: { userProfile in
                if let userProfile = userProfile {
                    XCTAssertEqual(userProfile, expectedUserProfile)
                    expectation.fulfill()
                } else {
                    XCTFail("userProfile is nil")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.naverSignInTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_NaverSignIn_실패_시_Error_전달받음() {
        let expectation = self.expectation(description: "Error 전달받음")
        
        viewModel.error
            .subscribe(onNext: { error in
                XCTAssertNotNil(error)
                if let nsError = error as NSError? {
                    XCTAssertEqual(nsError.domain, "TestError")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected an NSError but got \(String(describing: error))")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.naverSignInTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_AppleSignIn_성공_시_email_값_전달받음() {
        let expectation = self.expectation(description: "email 값 전달받음")
        
        let expectedUserProfile = UserProfile(id: "123", provider: "Kakao", name: "Yuk",  nickname: nil, imageUrl: nil)
        mockSignInUseCase.mockResult = .success(expectedUserProfile)
        
        viewModel.userProfile
            .skip(1)
            .subscribe(onNext: { userProfile in
                if let userProfile = userProfile {
                    XCTAssertEqual(userProfile, expectedUserProfile)
                    expectation.fulfill()
                } else {
                    XCTFail("userProfile is nil")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.appleSignInTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_AppleSignIn_실패_시_Error_전달받음() {
        let expectation = self.expectation(description: "Error 전달받음")
        
        viewModel.error
            .subscribe(onNext: { error in
                XCTAssertNotNil(error)
                if let nsError = error as NSError? {
                    XCTAssertEqual(nsError.domain, "TestError")
                    expectation.fulfill()
                } else {
                    XCTFail("Expected an NSError but got \(String(describing: error))")
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.appleSignInTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
