import Foundation
import RxSwift
import AuthenticationServices
import FirebaseAuth
import CryptoKit

protocol AppleSignRemoteDataSource {
    func signInWithApple(nonce: String, completion: @escaping (Result<String, Error>) -> Void)
}

class AppleSignRemoteDataSourceImpl: NSObject, AppleSignRemoteDataSource {
    private var currentNonce: String?
    private var authDelegate: ASAuthorizationControllerDelegate?
    private var completion: ((Result<String, Error>) -> Void)?
    
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

// MARK: - Apple SignIn Delegate
extension AppleSignRemoteDataSourceImpl: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                self.completion?(.failure(NSError(domain: "AppleIDTokenError", code: -1, userInfo: nil)))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.completion?(.failure(NSError(domain: "TokenSerializationError", code: -1, userInfo: nil)))
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
                    self.completion?(.success(uid))
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.completion?(.failure(error))
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
}
