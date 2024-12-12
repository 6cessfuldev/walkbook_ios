import UIKit

protocol AuthenticationRepository {
    func signInWithApple(nonce: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func signInWithKakao(completion: @escaping (Result<UserProfile, Error>) -> Void)
    func signInWithNaver(completion: @escaping (Result<UserProfile, Error>) -> Void)
}
