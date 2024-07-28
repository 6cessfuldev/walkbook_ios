import Foundation
import FirebaseFunctions
import FirebaseAuth

protocol FirebaseAuthRemoteDataSource {
    func createCustomToken(provider: String, uid: String, completion: @escaping (Result<String, Error>) -> Void)
    func signInWithCustomToken(token: String, completion: @escaping (Result<String, Error>) -> Void)
}

class FirebaseAuthRemoteDataSourceImpl: FirebaseAuthRemoteDataSource {
    
    private let functions = Functions.functions()
    
    func createCustomToken(provider: String, uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let data = [
            "uid": "\(provider):\(uid)"
        ]
        
        functions.httpsCallable("createCustomToken").call(data) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let token = (result?.data as? [String: Any])?["token"] as? String {
                completion(.success(token))
            } else {
                let error = NSError(domain: "FirebaseAuthRemoteDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(.failure(error))
            }
        }
    }
    
    func signInWithCustomToken(token: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withCustomToken: token) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                let error = NSError(domain: "FirebaseAuthRemoteDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])
                completion(.failure(error))
                return
            }
            
            completion(.success(user.uid))
        }
    }
}
