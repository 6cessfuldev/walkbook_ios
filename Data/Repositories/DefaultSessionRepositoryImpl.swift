import Foundation

class DefaultSessionRepositoryImpl: SessionRepository {
    
    private let localDataSource: LocalDataSource
    
    private var userProfile: UserProfile?
    private let queue = DispatchQueue(label: "com.iosyuk.walkbook.sessionRepository", attributes: .concurrent)
    
    private enum LocalDataKeys {
        static let userProfile = "userProfile"
    }

    init(localDataSource: LocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getUserProfile() -> Result<UserProfile, Error> {
        var profile: UserProfile?
        queue.sync {
            profile = self.userProfile
        }

        if let cachedProfile = profile {
            return .success(cachedProfile)
        } else {
            guard let data = localDataSource.fetchData(forKey: LocalDataKeys.userProfile) else {
                return .failure(NSError(domain: "LocalDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No user profile found in local storage."]))
            }
            do {
                let decoder = JSONDecoder()
                let modelData = try decoder.decode(UserProfileModel.self, from: data)
                let userProfile = UserProfileMapper.toEntity(modelData)
                return .success(userProfile)
            } catch {
                print("Failed to decode UserProfile: \(error)")
                return .failure(error)
            }
        }
    }

    func saveUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async(flags: .barrier) {
            self.userProfile = userProfile
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(UserProfileMapper.toModel(userProfile))
                self.localDataSource.saveData(data, forKey: LocalDataKeys.userProfile)
                completion(.success(()))
            } catch {
                print("Failed to encode UserProfile: \(error)")
                completion(.failure(error))
            }
        }
    }

    func removeUserProfile() {
        queue.async(flags: .barrier) {
            self.userProfile = nil
        }
        localDataSource.removeData(forKey: LocalDataKeys.userProfile)
    }
}
