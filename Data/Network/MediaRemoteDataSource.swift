import Foundation
import FirebaseStorage

protocol MediaRemoteDataSource {
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void)
    func uploadAudio(_ audioFileURL: URL, completion: @escaping (Result<String, Error>) -> Void)
}

class FirebaseStorageMediaRemoteDataSourceImpl: MediaRemoteDataSource {
    
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
    
    func uploadAudio(_ audioFileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let audioRef = storage.reference().child("audios/\(UUID().uuidString).m4a")
        audioRef.putFile(from: audioFileURL, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            audioRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
    
    
}
