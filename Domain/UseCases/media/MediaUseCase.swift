import UIKit

protocol MediaUseCaseProtocol {
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void)
    func uploadAudio(_ audioFileURL: URL, completion: @escaping (Result<String, Error>) -> Void)
}

class DefaultMediaUseCase: MediaUseCaseProtocol {
    
    private let repository: MediaRepository
    
    init(repository: MediaRepository) {
        self.repository = repository
    }
    
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void) {
        repository.uploadImage(image, completion: completion)
    }
    
    func uploadAudio(_ audioFileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        repository.uploadAudio(audioFileURL, completion: completion)
    }
}
