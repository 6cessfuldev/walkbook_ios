protocol UserProfileRepository {
    func getUserProfile(byId id: String, completion: @escaping (Result<UserProfile, Error>) -> Void)
    func updateUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void)
}
