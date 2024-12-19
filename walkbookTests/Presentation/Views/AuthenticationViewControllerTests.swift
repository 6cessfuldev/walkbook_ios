import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import walkbook

class AuthenticationViewControllerTests: XCTestCase {

    var viewController: AuthenticationViewController!
    var mockViewModel: AuthenticationViewModel!
    var mockuserProfileViewModel: UserProfileViewModel!
    var coordinator: MockAuthenticationFlowCoordinator!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        mockViewModel = AuthenticationViewModel(
            userProfileViewModel: mockuserProfileViewModel,
            googleSignInUseCase: MockGoogleSignInUseCase(),
            kakaoSignInUseCase: MockKakaoSignInUseCase(),
            naverSignInUseCase: MockNaverSignInUseCase(),
            appleSignInUseCase: MockAppleSignInUseCase()
        )
        coordinator = MockAuthenticationFlowCoordinator(navigationController: UINavigationController(), dependencies: AppDIContainer())
        viewController = AuthenticationViewController(viewModel: mockViewModel)
        viewController.coordinator = coordinator
        
        _ = viewController.view
    }
    
    override func tearDown() {
        disposeBag = nil
        mockViewModel = nil
        viewController = nil
        super.tearDown()
    }

    func test_이메일_정보_받을_경우_MainVC로_화면전환로직_호출() throws {
        let emailSubject = scheduler.createHotObservable([.next(10, UserProfile(id: "1", provider: "Apple", name: "user@example.com", nickname: nil, imageUrl: nil))])
        emailSubject.bind(to: mockViewModel.userProfile).disposed(by: disposeBag)

        scheduler.start()

        XCTAssertTrue(coordinator.didFinishAuthenticationCalled)
    }
}

class MockAuthenticationFlowCoordinator: AuthenticationFlowCoordinator {
    var didFinishAuthenticationCalled = false
    
    override func didFinishAuthentication() {
        didFinishAuthenticationCalled = true
    }
}
