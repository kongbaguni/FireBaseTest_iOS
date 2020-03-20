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
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        migrationRealm()
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        signin()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
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
                userInfo.syncData { (isNew) in
                    if isNew {
                        AdminOptions.shared.getData {
                            UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController:  MyProfileViewController.viewController)
                        }
                    } else {
                        AdminOptions.shared.getData {
                            UIApplication.shared.windows.first?.rootViewController  = MainTabBarController.viewController
                        }
                    }
                }
            }
            else {
                UserInfo.info?.logout()
            }
        }
    }
    
    private func migrationRealm() {

        Realm.Configuration.defaultConfiguration =  Realm.Configuration(
            schemaVersion: Consts.REALM_VERSION,

            migrationBlock: { migration, oldSchemaVersion in
//                if (oldSchemaVersion < 1) {
//                }
            })

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
        if let vc = UIApplication.shared.windows.first?.rootViewController as? LoginViewController {
            vc.autologinBgView.isHidden = false
            vc.indicator.startAnimating()
        }

        Auth.auth().signIn(with: credential) {(authResult, error) in
            
            if error == nil {
                if UserInfo.info == nil {
                    authResult?.saveUserInfo(idToken: authentication.idToken, accessToken: authentication.accessToken)
                    StoreModel.deleteAll()
                    UserInfo.info?.syncData(complete: { (isNew) in
                        AdminOptions.shared.getData {
                            if isNew {
                                UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController:  MyProfileViewController.viewController)
                            }
                            else {
                                UIApplication.shared.windows.first?.rootViewController  = MainTabBarController.viewController
                            }
                        }
                    })
                } else {
                    AdminOptions.shared.getData {
                        UIApplication.shared.windows.first?.rootViewController  = MainTabBarController.viewController
                    }
                }
                
            }
        }
    }
}

