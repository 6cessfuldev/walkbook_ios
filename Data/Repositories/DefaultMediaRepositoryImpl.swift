import Foundation

class DefaultStorageMediaRepositoryImpl: MediaRepository {
    private let mediaRemoteDataSource: MediaRemoteDataSource
    
    init(mediaRemoteDataSource: MediaRemoteDataSource) {
        self.mediaRemoteDataSource = mediaRemoteDataSource
    }
    
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        mediaRemoteDataSource.uploadImage(image, completion: completion)
    }
    
    func uploadAudio(_ audioFileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        mediaRemoteDataSource.uploadAudio(audioFileURL, completion: completion)
    }
}
