import Foundation
import RxSwift
import RxCocoa
import CryptoKit
import AuthenticationServices

enum AuthenticationState {
    case chooseLogin
    case signIn
    case signUp
}

class AuthenticationViewModel {
    private let userProfileViewModel: UserProfileViewModel
    private let googleSignInUseCase: GoogleSignInUseCaseProtocol
    private let kakaoSignInUseCase: KakaoSignInUseCaseProtocol
    private let naverSignInUseCase: NaverSignInUseCaseProtocol
    private let appleSignInUseCase: AppleSignInUseCaseProtocol
    
    // Inputs
    let signInTapped = PublishSubject<Void>()
    let signUpTapped = PublishSubject<Void>()
    let googleSignInTapped = PublishSubject<UIViewController>()
    let kakaoSignInTapped = PublishSubject<Void>()
    let naverSignInTapped = PublishSubject<Void>()
    let appleSignInTapped = PublishSubject<Void>()
    
    // Outputs
    let currentState = BehaviorRelay<AuthenticationState>(value: .chooseLogin)
    let userProfile = BehaviorRelay<UserProfile?>(value: nil)
    let error = PublishSubject<Error?>()
    
    private let disposeBag = DisposeBag()
    private var currentNonce: String?
    
    init(
        userProfileViewModel: UserProfileViewModel,
        googleSignInUseCase: GoogleSignInUseCaseProtocol,
        kakaoSignInUseCase: KakaoSignInUseCaseProtocol,
        naverSignInUseCase: NaverSignInUseCaseProtocol,
        appleSignInUseCase: AppleSignInUseCaseProtocol)
    {
        self.userProfileViewModel = userProfileViewModel
        self.googleSignInUseCase = googleSignInUseCase
        self.kakaoSignInUseCase = kakaoSignInUseCase
        self.naverSignInUseCase = naverSignInUseCase
        self.appleSignInUseCase = appleSignInUseCase
        setupBindings()
    }
    
    private func setupBindings() {
        signInTapped
            .subscribe(onNext: { [weak self] in
                self?.currentState.accept(.signIn)
            })
            .disposed(by: disposeBag)
        
        signUpTapped
            .subscribe(onNext: { [weak self] in
                self?.currentState.accept(.signUp)
            })
            .disposed(by: disposeBag)
        
        googleSignInTapped
            .subscribe(onNext: { [weak self] viewController in
                self?.signInWithGoogleFlow(presenting: viewController)
            })
            .disposed(by: disposeBag)
        
        kakaoSignInTapped
            .subscribe(onNext: { [weak self] in
                self?.signInWithKakaoFlow()
            })
            .disposed(by: disposeBag)
        
        naverSignInTapped
            .subscribe(onNext: { [weak self] in
                self?.signInWithNaverFlow()
            })
            .disposed(by: disposeBag)
        
        appleSignInTapped
            .subscribe(onNext: { [weak self] in
                self?.startSignInWithAppleFlow()
            })
            .disposed(by: disposeBag)
        
    }
    
    private func startSignInWithAppleFlow() {
        let nonce = NonceUtils.randomNonceString()
        currentNonce = nonce
        appleSignInUseCase.execute(nonce: nonce) { [weak self] result in
            switch result {
            case .success(let userProfile):
                self?.userProfileViewModel.signIn(user: userProfile)
                self?.userProfile.accept(userProfile)
            case .failure(let error):
                self?.error.onNext(error)
            }
        }
    }
    
    private func signInWithKakaoFlow() {
        kakaoSignInUseCase.execute { [weak self] result in
            switch result {
            case .success(let userProfile):
                self?.userProfileViewModel.signIn(user: userProfile)
                self?.userProfile.accept(userProfile)
            case .failure(let error):
                self?.error.onNext(error)
            }
        }
    }
    
    private func signInWithGoogleFlow(presenting viewController: UIViewController) {
        googleSignInUseCase.execute(presenting: viewController) { [weak self] result in
            switch result {
            case .success(let userProfile):
                self?.userProfileViewModel.signIn(user: userProfile)
                self?.userProfile.accept(userProfile)
            case .failure(let error):
                self?.error.onNext(error)
            }
        }
    }
    
    private func signInWithNaverFlow() {
        naverSignInUseCase.execute { [weak self] result in
            switch result {
            case .success(let userProfile):
                self?.userProfileViewModel.signIn(user: userProfile)
                self?.userProfile.accept(userProfile)
            case .failure(let error):
                self?.error.onNext(error)
            }
        }
    }
}
