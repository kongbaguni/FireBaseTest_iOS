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
                set(value.phoneNumber, forKey: "userPhoneNumber")
                set(value.authVerificationID, forKey: "authVerificationID")
            }
            else {
                self.userInfo?.profileImage = nil
                set(nil, forKey: "userPhoneNumber")
                set(nil, forKey: "authVerificationID")
            }
        }
        get {
            if let phoneNumber = string(forKey: "userPhoneNumber"), let id = string(forKey: "authVerificationID") {
                return UserInfo(phoneNumber: phoneNumber, authVerificationID: id)
            }
            return nil
        }
    }
}
