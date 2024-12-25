import Foundation

protocol MediaRepository {
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void)
    func uploadAudio(_ audioFileURL: URL, completion: @escaping (Result<String, Error>) -> Void)
}
