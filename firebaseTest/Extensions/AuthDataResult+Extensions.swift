//
//  AuthDataResult+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseAuth
import RealmSwift

extension AuthDataResult {
    var name:String? {
        return additionalUserInfo?.profile?["name"] as? String ?? email?.components(separatedBy: "@").first
    }
    var email:String? {
        return additionalUserInfo?.profile?["email"] as? String
    }
    
    func saveUserInfo(idToken:String,accessToken:String, complete:@escaping(_ isNewUser:Bool?)->Void) {
        
        func saveToken(email:String) {
            let realm = try! Realm()
            if let userInfo = realm.object(ofType: UserInfo.self, forPrimaryKey: email) {
                realm.beginWrite()
                userInfo.idToken = idToken
                userInfo.accessToken = accessToken
                try! realm.commitWrite()
            }
        }
        if let userInfo = self.additionalUserInfo,
            let profile = userInfo.profile {
            let name = self.name ?? ""
            let profileUrl = profile["picture"] as? String  ?? ""
            UserDefaults.standard.set(profileUrl, forKey: "profileTemp")
            if let email = profile["email"] as? String {
                if let userInfo = try! Realm().object(ofType: UserInfo.self, forPrimaryKey: email) {
                    if profileUrl.isEmpty == false {
                        userInfo.update(data: ["profileImageURLgoogle":profileUrl]) { (isSucess) in
                            saveToken(email: email)
                            complete(false)
                        }
                    } else {
                        saveToken(email: email)
                        complete(false)
                    }
                } else {
                    UserInfo.createUser(email: email, name: name, searchDistance: Consts.SEARCH_DISTANCE_LIST.first!, mapType: UserInfo.MapType.standard.rawValue,
                                        profileImageURL: nil, googleProfileUrl: profileUrl) { (isNewUser) in
                                            saveToken(email: email)
                                            complete(isNewUser)
                    }
                }
            }
        }
    }
}
