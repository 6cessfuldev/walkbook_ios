//
//  AppDelegate.swift
//  walkbook
//
//  Created by 육성민 on 7/10/24.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import RxKakaoSDKCommon
import NaverThirdPartyLogin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let kakaoNativeAppKey = Bundle.main.object(forInfoDictionaryKey: "KakaoNativeAppKey") as? String {
            RxKakaoSDK.initSDK(appKey: kakaoNativeAppKey)
        }
        
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isNaverAppOauthEnable = true
        instance?.isInAppOauthEnable = true
        instance?.isOnlyPortraitSupportedInIphone()
        
        if let naverServiceAppUrlScheme = Bundle.main.object(forInfoDictionaryKey: "NaverServiceAppUrlScheme") as? String,
           let naverConsumerKey = Bundle.main.object(forInfoDictionaryKey: "NaverConsumerKey") as? String,
           let naverConsumerSecret = Bundle.main.object(forInfoDictionaryKey: "NaverConsumerSecret") as? String,
           let naverServiceAppName = Bundle.main.object(forInfoDictionaryKey: "NaverServiceAppName") as? String {
            instance?.serviceUrlScheme = naverServiceAppUrlScheme
            instance?.consumerKey = naverConsumerKey
            instance?.consumerSecret = naverConsumerSecret
            instance?.appName = naverServiceAppName
        }
        
        FirebaseApp.configure()
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    
        NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

