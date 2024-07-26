import XCTest
import RxSwift
import RxCocoa
@testable import walkbook

class AuthenticationViewModelTests: XCTestCase {
    
    var viewModel: AuthenticationViewModel!
    var mockUseCase: MockAppleSignInUseCase!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockAppleSignInUseCase()
        viewModel = AuthenticationViewModel(appleSignInUseCase: mockUseCase)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
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
    
    func test_AppleSignIn_성공_시_email_값_전달받음() {
        let expectation = self.expectation(description: "email 값 전달받음")
        
        viewModel.userEmail
            .subscribe(onNext: { email in
                XCTAssertEqual(email, self.mockUseCase.mockEmail)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        viewModel.appleSignInTapped.onNext(())
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_AppleSignIn_실패_시_Error_전달받음() {
        let expectation = self.expectation(description: "Error 전달받음")
        mockUseCase.shouldReturnError = true
        
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
