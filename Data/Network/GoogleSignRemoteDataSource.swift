import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

protocol GoogleSignRemoteDataSource {
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void)
}

class GoogleSignRemoteDataSourceImpl: GoogleSignRemoteDataSource {
    private var completion: ((Result<String, Error>) -> Void)?
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "GoogleLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing client ID"])))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [unowned self] result, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            guard
                let user = result?.user, let idToken = user.idToken?.tokenString
            else {
                completion(.failure(NSError(domain: "GoogleLoginError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing authentication"])))
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.completion?(.failure(error))
                    return
                }
                
                if let user = Auth.auth().currentUser {
                    let uid = user.uid
                    let email = user.email
                    let displayName = user.displayName
                    let photoURL = user.photoURL
                    let emailVerified = user.isEmailVerified
                    
                    // Print user info
                    print("User ID: \(uid)")
                    print("User Email: \(String(describing: email))")
                    print("Display Name: \(String(describing: displayName))")
                    print("Photo URL: \(String(describing: photoURL))")
                    print("Email Verified: \(emailVerified)")
                    self.completion?(.success(email ?? ""))
                }
            }
        }
    }
}
