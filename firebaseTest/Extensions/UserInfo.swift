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
    
    var profileImageURL:String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "profileImageUrl")
        }
        get {
            UserDefaults.standard.string(forKey: "profileImageUrl")
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
        profileImageURL = nil
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
                    if let url = info["profileImageUrl"] as? String {
                        self?.profileImageURL = url
                    }
                    complete()                    
                }
            }
        }
    }
}
