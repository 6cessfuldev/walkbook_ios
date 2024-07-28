import UIKit

protocol AuthenticationRepository {
    func signInWithApple(nonce: String, completion: @escaping (Result<String, Error>) -> Void)
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void)
    func signInWithKakao(completion: @escaping (Result<String, Error>) -> Void)
    func signInWithNaver(completion: @escaping (Result<String, Error>) -> Void)
}
