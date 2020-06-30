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
import SwiftyStoreKit

fileprivate let gcmMessageIDKey = "gcm.message_id"
fileprivate let gcmNotificationTarget = "gcm.notification.target"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window:UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        migrationRealm()
        
        Messaging.messaging().isAutoInitEnabled = true
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        signin()
        
        getNotificationSettings()
        //        Messaging.messaging().delegate = self
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                print(purchase)
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)                        
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                default:
                    break
                }
            }
        }
        return true
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        Messaging.messaging().delegate = self
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance()?.handle(url) ?? false
    }
    
    /** 자동 로그인 (구글 auth)*/
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
                            let vc = MyProfileViewController.viewController
                            vc.hideLeaveCell = true
                            vc.authDataResult = authResult
                            UIApplication.shared.rootViewController = UINavigationController(rootViewController:vc)
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
                if let id = authResult?.email {
                    UserInfo.getUserInfo(id: id) { (isSucess) in
                        if isSucess {
                            let realm = try! Realm()
                            var user = realm.object(ofType: UserInfo.self, forPrimaryKey: id)
                            realm.beginWrite()
                            var data:[String:Any] = [
                                "email": id,
                                "idToken":authentication.idToken ?? "",
                                "accessToken":authentication.accessToken ?? ""
                            ]
                            
                            var data2:[String:Any] = [
                                "email": id,
                            ]

                            if (user?.profileImageURLgoogle.isEmpty ?? false) == true {
                                if let url = authResult?.pictureURL {
                                    data["isDeleteProfileImage"] = user?.profileImageURL == nil
                                    data["profileImageURLgoogle"] = url
                                    
                                    data2["isDeleteProfileImage"] = user?.profileImageURL == nil
                                    data2["profileImageURLgoogle"] = url
                                }
                            }
                            user = realm.create(UserInfo.self, value: data, update: .modified)
                            try! realm.commitWrite()
                            user?.update(data: data2) { (sucess) in
                                AdminOptions.shared.getData {
                                    UIApplication.shared.rootViewController  = MainTabBarController.viewController
                                }
                            }
                        } else {
                            let vc = TermViewController.viewController
                            vc.authResult = authResult
                            vc.idTokenString = authentication.idToken
                            vc.accessToken = authentication.accessToken
                            UIApplication.shared.rootViewController = vc
                        }
                    }
                }
            }
            else {
                if let vc = UIApplication.shared.rootViewController as? LoginViewController {
                    vc.autologinBgView.isHidden = true
                    vc.loading.hide()
                }
            }
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        debugPrint(userInfo)
        //            let target = userInfo[gcmNotificationTarget]
        //        switch target {
        //        case "catPrint":
        //            break
        //        default:
        //            break
        //        }
        
        //            let vc = MessageViewController.viewController
        //            vc.userInfo = userInfo
        //            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("UNUserNotificationCenterDelegate willPresent notification = \(notification)")
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler([.alert, .sound, .badge])
    }
    
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //        UserDefaults.standard.fcmToken = fcmToken
        let realm = try! Realm()
        realm.beginWrite()
        UserInfo.info?.fcmID = fcmToken
        try! realm.commitWrite()
        UserInfo.info?.update(data: ["fcmId":fcmToken], complete: { isSucess in
            
        })
        debugPrint("\(#function) \(#line)")
        debugPrint("fcmToken : \(fcmToken)")
    }
}
