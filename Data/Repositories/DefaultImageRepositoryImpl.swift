import Foundation

class DefaultStorageImageRepositoryImpl: ImageRepository {
    private let imageRemoteDataSource: ImageRemoteDataSource
    
    init(imageRemoteDataSource: ImageRemoteDataSource) {
        self.imageRemoteDataSource = imageRemoteDataSource
    }
    
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        imageRemoteDataSource.uploadImage(image, completion: completion)
    }
}
