//
//  UserDefault+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
extension UserDefaults {
    var userInfo:UserInfo? {
        set {
            if let value = newValue {
                set(value.id, forKey: "userId")
                set(value.authVerificationID, forKey: "authVerificationID")
            }
            else {
                self.userInfo?.clear()
                set(nil, forKey: "userId")
                set(nil, forKey: "authVerificationID")
            }
        }
        get {
            if let phoneNumber = string(forKey: "userPhoneNumber"), let id = string(forKey: "authVerificationID") {
                return UserInfo(id: phoneNumber.sha512, authVerificationID: id)
            }
            return nil
        }
    }
}
