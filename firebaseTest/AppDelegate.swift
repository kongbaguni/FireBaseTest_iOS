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

    var window:UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        migrationRealm()
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        signin()
        return true
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
                                UIApplication.shared.rootViewController = UINavigationController(rootViewController:  MyProfileViewController.viewController)
                        }
                    } else {
                        AdminOptions.shared.getData {
                            UIApplication.shared.rootViewController  = MainTabBarController.viewController
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
        if let vc = UIApplication.shared.rootViewController as? LoginViewController {
            vc.autologinBgView.isHidden = false
            vc.loading.show(viewController: vc)
        }

        Auth.auth().signIn(with: credential) {(authResult, error) in
            
            if error == nil {
                if UserInfo.info == nil {
                    authResult?.saveUserInfo(idToken: authentication.idToken, accessToken: authentication.accessToken)
                    StoreModel.deleteAll()
                    UserInfo.info?.syncData(complete: { (isNew) in
                        AdminOptions.shared.getData {
                            if isNew {
                                UIApplication.shared.rootViewController = UINavigationController(rootViewController:  MyProfileViewController.viewController)
                            }
                            else {
                                UIApplication.shared.rootViewController  = MainTabBarController.viewController
                            }
                        }
                    })
                } else {
                    AdminOptions.shared.getData {
                        UIApplication.shared.rootViewController  = MainTabBarController.viewController
                    }
                }
                
            }
        }
    }
}

