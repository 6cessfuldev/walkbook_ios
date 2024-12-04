import Foundation
import Alamofire
import NaverThirdPartyLogin

protocol NaverSignRemoteDataSource {
    func signInWithNaver(completion: @escaping (Result<String, Error>) -> Void)
}

class NaverSignRemoteDataSourceImpl: NSObject, NaverSignRemoteDataSource {
    private let instance = NaverThirdPartyLoginConnection.getSharedInstance()
    private var completion: ((Result<String, Error>) -> Void)?
    
    func signInWithNaver(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        login()
    }
    
    private func getInfo() {
        
        guard let isValidAccessToken = instance?.isValidAccessTokenExpireTimeNow() else {
            login()
            return
        }
        
        if !isValidAccessToken {
            refreshToken()
            return
        } else {
            userInfo()
        }
    }
    
    private func login() {
        instance?.delegate = self
        instance?.requestThirdPartyLogin()
    }
    
    private func refreshToken() {
        instance?.delegate = self
        self.instance?.requestAccessTokenWithRefreshToken()
    }
    
    func logout() {
        instance?.delegate = self
        instance?.resetToken()
    }
    
    func disConnect() {
        instance?.delegate = self
        instance?.requestDeleteToken()
    }
    
    private func userInfo() {
        guard let tokenType = instance?.tokenType, let accessToken = instance?.accessToken else {
            completion?(.failure(NSError(domain: "NaverSignRemoteDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token not available"])))
            return
        }
        
        let urlStr = "https://openapi.naver.com/v1/nid/me"
        let url = URL(string: urlStr)!
        
        let authorization = "\(tokenType) \(accessToken)"
        let req = AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": authorization])
        
        req.responseDecodable(of: NaverLogin.self) { [self] response in
            print(response)
            print(response.result)
            
            switch response.result {
            case .success(let loginData):
                self.completion?(.success(loginData.response.id))
                break
            case .failure(let error):
                print("error: \(error.localizedDescription)")
                self.completion?(.failure(error))
                break
            }
        }
    }
}

//MARK: - Naver Login Delegate
extension NaverSignRemoteDataSourceImpl: NaverThirdPartyLoginConnectionDelegate {
    // 로그인에 성공한 경우 호출 됨
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("네이버 로그인 성공")
        getInfo()
    }
    // 토큰 갱신 성공 시 호출 됨
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("네이버 토큰 갱신 성공")
        getInfo()
    }
    // 연동해제 성공한 경우 호출 됨
    func oauth20ConnectionDidFinishDeleteToken() {
        print("네이버 연동 해제 성공")
    }
    // 모든 error인 경우 호출 됨
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        let alert = UIAlertController(title: "네이버 SNS 로그인 실패", message: "이유: \(String(error.localizedDescription))", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        
        if let vc = UIApplication.topViewController(base: nil) {
            vc.present(alert, animated: true)
        }
    }
}

struct NaverLogin: Decodable {
    var resultCode: String
    var response: Response
    var message: String
    
    struct Response: Decodable {
        var email: String?
        var id: String
        var name: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case resultCode = "resultcode"
        case response
        case message
    }
}
