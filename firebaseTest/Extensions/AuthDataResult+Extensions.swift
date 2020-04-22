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
            if let name = profile["name"] as? String,
                let email = profile["email"] as? String,
                let profileUrl = profile["picture"] as? String {
                if let userInfo = try! Realm().object(ofType: UserInfo.self, forPrimaryKey: email) {
                    userInfo.update(data: ["profileImageURLgoogle":profileUrl]) { (isSucess) in
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
