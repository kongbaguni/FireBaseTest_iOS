//
//  UserInfo.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/03.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class UserInfo {
    let phoneNumber:String
    let authVerificationID:String
    
    var photoBase64String:String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "profileImageBase64String")
        }
        get {
            UserDefaults.standard.string(forKey: "profileImageBase64String")
        }
    }
    
    var profileImage:UIImage? {
        set {
            let photo = newValue?.af_imageAspectScaled(toFit: CGSize(width: 30, height: 30))
            let str = photo?.pngData()?.base64EncodedString()
            photoBase64String = str
        }
        get {
            if let str = photoBase64String {
                if let data = Data(base64Encoded: str) {
                    return UIImage(data: data)
                }
            }
            return nil
        }
    }
    
    init(phoneNumber:String,authVerificationID:String) {
        self.phoneNumber = phoneNumber
        self.authVerificationID = authVerificationID
    }
}
