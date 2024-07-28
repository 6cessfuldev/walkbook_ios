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
            .subscribe(onNext:{ (oauthToken) in
                print("loginWithKakaoAccount() success.")

                self.completion?(.success(oauthToken.accessToken))
            }, onError: {error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
