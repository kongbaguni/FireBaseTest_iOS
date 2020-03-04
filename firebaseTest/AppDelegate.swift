//
//  AppDelegate.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        signin()
        return true
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance()?.handle(url) ?? false
    }

    private func signin() {
        guard let userInfo = UserInfo.info else {
            return
        }
        let realm = try! Realm()
        realm.beginWrite()
        let credential = GoogleAuthProvider.credential(withIDToken: userInfo.idToken, accessToken: userInfo.accessToken)
        try! realm.commitWrite()
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error == nil {
                UIApplication.shared.windows.first?.rootViewController  = MainNavigationController.viewController
            }
        }
    }

}

extension AppDelegate : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) {(authResult, error) in
            if error == nil {
                if UserInfo.info == nil {
                    if let userInfo = authResult?.additionalUserInfo,
                        let profile = userInfo.profile {
                        if let name = profile["name"] as? String,
                            let email = profile["email"] as? String,
                            let profileUrl = profile["picture"] as? String {
                            
                            let userInfo = UserInfo()
                            userInfo.name = name
                            userInfo.profileImageURLgoogle = profileUrl
                            userInfo.email = email
                            userInfo.accessToken = authentication.accessToken
                            userInfo.idToken = authentication.idToken
                            let realm = try! Realm()
                            realm.beginWrite()
                            realm.add(userInfo)
                            try! realm.commitWrite()
                        }
                    }
                }
                UIApplication.shared.windows.first?.rootViewController  = MainNavigationController.viewController
            }
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

