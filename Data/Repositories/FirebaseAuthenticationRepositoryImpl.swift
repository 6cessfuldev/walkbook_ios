import Foundation
import UIKit

class FirebaseAuthenticationRepositoryImpl: NSObject, AuthenticationRepository {
    
    private let googleSignRemoteDataSource: GoogleSignRemoteDataSource
    private let kakaoSignRemoteDataSource: KakaoSignRemoteDataSource
    private let appleSignRemoteDataSource: AppleSignRemoteDataSource
    
    init(
        googleSignRemoteDataSource: GoogleSignRemoteDataSource,
        kakaoSignRemoteDataSource: KakaoSignRemoteDataSource,
        appleSignRemoteDataSource: AppleSignRemoteDataSource)
    {
        self.googleSignRemoteDataSource = googleSignRemoteDataSource
        self.kakaoSignRemoteDataSource = kakaoSignRemoteDataSource
        self.appleSignRemoteDataSource = appleSignRemoteDataSource
    }
    
    func signInWithApple(nonce: String, completion: @escaping (Result<String, Error>) -> Void) {
        appleSignRemoteDataSource.signInWithApple(nonce: nonce, completion: completion)
    }
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        googleSignRemoteDataSource.signInWithGoogle(presenting: viewController, completion: completion)
    }
    
    func signInWithKakao(completion: @escaping (Result<String, Error>) -> Void) {
        kakaoSignRemoteDataSource.signInWithKakao(completion: completion)
    }
}
