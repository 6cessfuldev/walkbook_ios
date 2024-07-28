import Foundation
import RxSwift
import RxKakaoSDKUser
import KakaoSDKUser

protocol KakaoSignRemoteDataSource {
    func signInWithKakao(completion: @escaping (Result<String, Error>) -> Void)
}

class KakaoSignRemoteDataSourceImpl: KakaoSignRemoteDataSource {
    private var completion: ((Result<String, Error>) -> Void)?
    private let disposeBag = DisposeBag()
    
    func signInWithKakao(completion: @escaping (Result<String, Error>) -> Void) {
        UserApi.shared.rx.loginWithKakaoAccount()
            .flatMap { oauthToken -> Single<KakaoSDKUser.User> in
                print("loginWithKakaoAccount() success.")
                return UserApi.shared.rx.me()
            }
            .subscribe(onNext: { user in
                guard let kakaoId = user.id else {
                    completion(.failure(NSError(domain: "KakaoSignRemoteDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])))
                    return
                }
                print("Kakao User ID: \(kakaoId)")
                completion(.success(String(kakaoId)))
            }, onError: { error in
                print("Error: \(error)")
                completion(.failure(error))
            })
            .disposed(by: disposeBag)
    }
}
