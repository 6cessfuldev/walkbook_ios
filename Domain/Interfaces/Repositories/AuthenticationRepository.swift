import UIKit

protocol AuthenticationRepository {
    func signInWithApple(nonce: String, completion: @escaping (Result<String, Error>) -> Void)
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void)
}
