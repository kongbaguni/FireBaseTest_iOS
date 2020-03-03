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
import FirebaseFirestore

class UserInfo {
    var id:String
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
    
    var name:String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "name")
        }
        get {
            UserDefaults.standard.string(forKey: "name")
        }
    }
    
    var introduce:String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "introduce")
        }
        get {
            UserDefaults.standard.string(forKey: "introduce")
        }
    }
    
    init(id:String,authVerificationID:String) {
        self.id = id
        self.authVerificationID = authVerificationID
    }
    
    func clear() {
        name = nil
        introduce = nil
        profileImage = nil
    }
    
    func syncData(complete:@escaping()->Void) {
        let dbCollection = Firestore.firestore().collection("users")
        let document = dbCollection.document(UserDefaults.standard.userInfo!.id)
        document.getDocument { [weak self](snapshot, error) in
            if let doc = snapshot {
                doc.data().map { info in
                    if let name = info["name"] as? String {
                        self?.name = name
                    }
                    if let intro = info["intro"] as? String {
                        self?.introduce = intro
                    }
                    if let profileImage = info["profileImage"] as? String {
                        if let data = Data(base64Encoded: profileImage) {
                            self?.profileImage = UIImage(data: data)
                        }
                    }
                    complete()                    
                }
            }
        }
    }
}
