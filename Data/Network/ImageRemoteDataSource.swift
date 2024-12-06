import Foundation
import FirebaseStorage

protocol ImageRemoteDataSource {
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void)
}

class FirebaseStorageImageRemoteDataSourceImpl: ImageRemoteDataSource {
    
    private let storage = Storage.storage()
    
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void) {
            let imageRef = storage.reference().child("images/\(UUID().uuidString).jpg")
            imageRef.putData(image, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    
    
}
