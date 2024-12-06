import Foundation

protocol ImageRepository {
    func uploadImage(_ image: Data, completion: @escaping (Result<String, Error>) -> Void)
}
