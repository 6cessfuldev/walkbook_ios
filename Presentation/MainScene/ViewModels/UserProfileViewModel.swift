import RxSwift
import RxCocoa

class UserProfileViewModel {
    
    let currentUser = BehaviorRelay<UserProfile?>(value: nil)
    
    func signIn(user: UserProfile) {
        currentUser.accept(user)
    }
    
    func signOut() {
        currentUser.accept(nil)
    }
}
