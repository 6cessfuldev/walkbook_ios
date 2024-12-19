import Foundation

protocol LocalDataSource {
    func fetchData(forKey key: String) -> Data?
    func saveData(_ data: Data, forKey key: String)
    func removeData(forKey key: String)
    func clearAllData()
}

class UserDefaultsLocalDataSourceImpl: LocalDataSource {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchData(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }

    func saveData(_ data: Data, forKey key: String) {
        userDefaults.set(data, forKey: key)
    }

    func removeData(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    func clearAllData() {
        guard let appDomain = Bundle.main.bundleIdentifier else { return }
        userDefaults.removePersistentDomain(forName: appDomain)
    }
}
