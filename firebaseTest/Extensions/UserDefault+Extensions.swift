//
//  UserDefault+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
extension UserDefaults {
    var authVerificationID:String? {
        set {
            set(newValue, forKey: "authVerificationID")
        }
        get {
            return string(forKey: "authVerificationID")
        }
    }
}
