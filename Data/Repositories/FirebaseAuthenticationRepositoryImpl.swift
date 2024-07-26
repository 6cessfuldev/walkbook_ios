import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class FirebaseAuthenticationRepositoryImpl: NSObject, AuthenticationRepository {
    
    private var completion: ((Result<String, Error>) -> Void)?
    private var currentNonce: String?
    private var authDelegate: ASAuthorizationControllerDelegate?
    
    func signInWithApple(nonce: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        self.currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = authDelegate ?? self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

// MARK: - Apple
extension FirebaseAuthenticationRepositoryImpl: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                completion?(.failure(NSError(domain: "AppleIDTokenError", code: -1, userInfo: nil)))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                completion?(.failure(NSError(domain: "TokenSerializationError", code: -1, userInfo: nil)))
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
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

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
}
