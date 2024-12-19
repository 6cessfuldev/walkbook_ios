import Foundation

class DefaultLocalStorageRepositoryImpl: LocalStorageRepository {
    private let localDataSource: LocalDataSource

    init(localDataSource: LocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getUserProfile() -> UserProfile? {
        guard let data = localDataSource.fetchData(forKey: "userProfile") else { return nil }
        do {
            let decoder = JSONDecoder()
            let modelData = try decoder.decode(UserProfileModel.self, from: data)
            return UserProfileMapper.toEntity(modelData)
        } catch {
            print("Failed to decode UserProfile: \(error)")
            return nil
        }
    }

    func saveUserProfile(_ userProfile: UserProfile) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(UserProfileMapper.toModel(userProfile))
            localDataSource.saveData(data, forKey: "userProfile")
        } catch {
            print("Failed to encode UserProfile: \(error)")
        }
    }

    func removeUserProfile() {
        localDataSource.removeData(forKey: "userProfile")
    }

    func clear() {
        localDataSource.clearAllData()
    }
}
