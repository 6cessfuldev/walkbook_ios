import UIKit

protocol ImageUseCaseProtocol {
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void)
}

class DefaultImageUseCase: ImageUseCaseProtocol {
    
    private let repository: ImageRepository
    
    init(repository: ImageRepository) {
        self.repository = repository
    }
    
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        repository.uploadImage(image, completion: completion)
    }
}
