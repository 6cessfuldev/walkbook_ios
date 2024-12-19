import Foundation
import RxSwift
import RxCocoa

@testable import walkbook

class MockUserProfileViewModel: UserProfileViewModel {
    
    private(set) var signInCallCount = 0
    private(set) var signOutCallCount = 0

    override func signIn(user: UserProfile) {
        signInCallCount += 1
        super.signIn(user: user)
    }

    override func signOut() {
        signOutCallCount += 1
        super.signOut()
    }
}
