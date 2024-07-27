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
    private let googleSignInUseCase: GoogleSignInUseCaseProtocol
    private let appleSignInUseCase: AppleSignInUseCase
    
    // Inputs
    let signInTapped = PublishSubject<Void>()
    let signUpTapped = PublishSubject<Void>()
    let googleSignInTapped = PublishSubject<UIViewController>()
    let appleSignInTapped = PublishSubject<Void>()
    
    // Outputs
    let currentState = BehaviorRelay<AuthenticationState>(value: .chooseLogin)
    let userEmail = PublishSubject<String?>()
    let error = PublishSubject<Error?>()
    
    private let disposeBag = DisposeBag()
    private var currentNonce: String?
    
    init(googleSignInUseCase: GoogleSignInUseCaseProtocol, appleSignInUseCase: AppleSignInUseCase) {
        self.googleSignInUseCase = googleSignInUseCase
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
            case .success(let email):
                print("Successfully signed in: \(email)")
                self?.userEmail.onNext(email)
            case .failure(let error):
                self?.error.onNext(error)
            }
        }
    }
    
    private func signInWithGoogleFlow(presenting viewController: UIViewController) {
        googleSignInUseCase.execute(presenting: viewController) { [weak self] result in
            switch result {
            case .success(let email):
                print("Successfully signed in: \(email)")
                self?.userEmail.onNext(email)
            case .failure(let error):
                self?.error.onNext(error)
            }
        }
    }
}
