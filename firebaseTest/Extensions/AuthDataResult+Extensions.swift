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
    func saveUserInfo(idToken:String,accessToken:String) {
        if let userInfo = self.additionalUserInfo,
            let profile = userInfo.profile {
            if let name = profile["name"] as? String,
                let email = profile["email"] as? String,
                let profileUrl = profile["picture"] as? String {
                
                let userInfo = UserInfo()
                userInfo.name = name
                userInfo.profileImageURLgoogle = profileUrl
                userInfo.email = email
                userInfo.idToken = idToken
                userInfo.accessToken = accessToken
                let realm = try! Realm()
                realm.beginWrite()
                realm.add(userInfo)
                try! realm.commitWrite()
            }
        }
    }
}