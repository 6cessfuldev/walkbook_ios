protocol SessionRepository {
    func getUserProfile() -> Result<UserProfile, Error>
    func saveUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void)
    func removeUserProfile()
}
