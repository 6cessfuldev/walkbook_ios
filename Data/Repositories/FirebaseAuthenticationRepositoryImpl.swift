import Foundation
import UIKit

class FirebaseAuthenticationRepositoryImpl: NSObject, AuthenticationRepository {
    private let googleSignRemoteDataSource: GoogleSignRemoteDataSource!
    private let kakaoSignRemoteDataSource: KakaoSignRemoteDataSource!
    private let naverSignRemoteDataSource: NaverSignRemoteDataSource!
    private let appleSignRemoteDataSource: AppleSignRemoteDataSource!
    private let firebaseAuthRemoteDataSource: FirebaseAuthRemoteDataSource!
    private let userProfileRemoteDataSource: UserProfileRemoteDataSource!
    
    init(
        googleSignRemoteDataSource: GoogleSignRemoteDataSource,
        kakaoSignRemoteDataSource: KakaoSignRemoteDataSource,
        naverSignRemoteDataSource: NaverSignRemoteDataSource,
        appleSignRemoteDataSource: AppleSignRemoteDataSource,
        firebaseAuthRemoteDataSource: FirebaseAuthRemoteDataSource,
        userProfileRemoteDataSource: UserProfileRemoteDataSource
    )
    {
        self.googleSignRemoteDataSource = googleSignRemoteDataSource
        self.kakaoSignRemoteDataSource = kakaoSignRemoteDataSource
        self.naverSignRemoteDataSource = naverSignRemoteDataSource
        self.appleSignRemoteDataSource = appleSignRemoteDataSource
        self.firebaseAuthRemoteDataSource = firebaseAuthRemoteDataSource
        self.userProfileRemoteDataSource = userProfileRemoteDataSource
    }
    
    func signInWithApple(nonce: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        appleSignRemoteDataSource.signInWithApple(nonce: nonce) { authResult in
            switch authResult {
            case .success(let uid):
                self.handleUserProfile(for: uid, provider: "apple") { profileResult in
                    switch profileResult {
                    case .success(let userProfile):
                        completion(.success(userProfile))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        googleSignRemoteDataSource.signInWithGoogle(presenting: viewController) { authResult in
            switch authResult {
            case .success(let uid):
                self.handleUserProfile(for: uid, provider: "google") { profileResult in
                    switch profileResult {
                    case .success(let userProfile):
                        completion(.success(userProfile))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signInWithKakao(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        kakaoSignRemoteDataSource.signInWithKakao { [weak self] result in
            switch result {
            case .success(let kakaoUid):
                self?.firebaseAuthRemoteDataSource.createCustomToken(provider: "kakao", uid: kakaoUid) { tokenResult in
                    switch tokenResult {
                    case .success(let customToken):
                        self?.firebaseAuthRemoteDataSource.signInWithCustomToken(token: customToken) { authResult in
                            switch authResult {
                            case .success(let uid):
                                self?.handleUserProfile(for: uid, provider: "kakao") { profileResult in
                                    switch profileResult {
                                    case .success(let userProfile):
                                        completion(.success(userProfile))
                                    case .failure(let error):
                                        completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func signInWithNaver(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        naverSignRemoteDataSource.signInWithNaver{ [weak self] result in
            switch result {
            case .success(let naverUid):
                self?.firebaseAuthRemoteDataSource.createCustomToken(provider: "naver", uid: naverUid) { tokenResult in
                    switch tokenResult {
                    case .success(let customToken):
                        self?.firebaseAuthRemoteDataSource.signInWithCustomToken(token: customToken) { authResult in
                            switch authResult {
                            case .success(let uid):
                                self?.handleUserProfile(for: uid, provider: "naver") { profileResult in
                                    switch profileResult {
                                    case .success(let userProfile):
                                        completion(.success(userProfile))
                                    case .failure(let error):
                                        completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func handleUserProfile(for uid: String, provider: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        userProfileRemoteDataSource.getUserProfile(byId: uid) { [weak self] result in
            switch result {
            case .success(let userProfileModel):
                let currentUserProfileModel = userProfileModel.copy(lastLoginDate: Date())
                self?.userProfileRemoteDataSource.updateUserProfile(currentUserProfileModel) { updateResult in
                    switch updateResult {
                    case .success:
                        completion(.success(UserProfileMapper.toEntity(currentUserProfileModel)))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                if error.localizedDescription.contains("not found") {
                    let newUserProfileModel = UserProfileModel(
                        id: uid,
                        provider: provider,
                        name: nil,
                        nickname: nil,
                        imageUrl: nil,
                        lastLoginDate: Date()
                    )
                    self?.userProfileRemoteDataSource.updateUserProfile(newUserProfileModel) { updateResult in
                        switch updateResult {
                        case .success:
                            completion(.success(UserProfileMapper.toEntity(newUserProfileModel)))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
}
