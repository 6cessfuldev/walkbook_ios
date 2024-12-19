protocol LocalStorageRepository {
    
    func getUserProfile() -> UserProfile?
    
    func saveUserProfile(_ userProfile: UserProfile)
    
    func removeUserProfile()
    
    func clear()
}
