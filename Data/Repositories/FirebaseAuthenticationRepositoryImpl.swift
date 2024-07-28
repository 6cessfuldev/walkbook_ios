import Foundation
import UIKit

class FirebaseAuthenticationRepositoryImpl: NSObject, AuthenticationRepository {
    
    private let googleSignRemoteDataSource: GoogleSignRemoteDataSource!
    private let kakaoSignRemoteDataSource: KakaoSignRemoteDataSource!
    private let appleSignRemoteDataSource: AppleSignRemoteDataSource!
    private let firebaseAuthRemoteDataSource: FirebaseAuthRemoteDataSource!
    
    init(
        googleSignRemoteDataSource: GoogleSignRemoteDataSource,
        kakaoSignRemoteDataSource: KakaoSignRemoteDataSource,
        appleSignRemoteDataSource: AppleSignRemoteDataSource,
        firebaseAuthRemoteDataSource: FirebaseAuthRemoteDataSource
    )
    {
        self.googleSignRemoteDataSource = googleSignRemoteDataSource
        self.kakaoSignRemoteDataSource = kakaoSignRemoteDataSource
        self.appleSignRemoteDataSource = appleSignRemoteDataSource
        self.firebaseAuthRemoteDataSource = firebaseAuthRemoteDataSource
    }
    
    func signInWithApple(nonce: String, completion: @escaping (Result<String, Error>) -> Void) {
        appleSignRemoteDataSource.signInWithApple(nonce: nonce, completion: completion)
    }
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        googleSignRemoteDataSource.signInWithGoogle(presenting: viewController, completion: completion)
    }
    
    func signInWithKakao(completion: @escaping (Result<String, Error>) -> Void) {
        kakaoSignRemoteDataSource.signInWithKakao { [weak self] result in
            switch result {
            case .success(let kakaoUid):
                self?.firebaseAuthRemoteDataSource.createCustomToken(provider: "kakao", uid: kakaoUid) { tokenResult in
                    switch tokenResult {
                    case .success(let customToken):
                        self?.firebaseAuthRemoteDataSource.signInWithCustomToken(token: customToken, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
