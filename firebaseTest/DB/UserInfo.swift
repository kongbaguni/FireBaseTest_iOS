//
//  UserInfo.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/03.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import RealmSwift

class UserInfo : Object {
    @objc dynamic var email                     : String    = ""
    @objc dynamic var name                      : String    = ""
    @objc dynamic var introduce                 : String    = ""
    @objc dynamic var profileImageURLgoogle     : String    = ""
    @objc dynamic var profileImageURLfirebase   : String    = ""
    @objc dynamic var idToken                   : String    = ""
    @objc dynamic var accessToken               : String    = ""
    @objc dynamic var updateDt                  : Date      = Date()
    /** 프로필 이미지 사용하지 않을 경우 true*/
    @objc dynamic var isDeleteProfileImage      : Bool      = false {
        didSet {
            if isDeleteProfileImage {
                profileImageURLfirebase = ""
            }
        }
    }
    
    static var info:UserInfo? {
        return try! Realm().objects(UserInfo.self).first
    }
    
    var profileImageURL:URL? {
        if isDeleteProfileImage {
            return nil
        }
        if let url = URL(string:profileImageURLfirebase) {
            return url
        }
        return URL(string:profileImageURLgoogle)
    }
    
    var id:String {
        return email.sha512
    }
                
    /** firebase 에서 데이터를 받아와서 사용자 정보를 갱신합니다.*/
    func syncData(complete:@escaping()->Void) {
        let dbCollection = Firestore.firestore().collection("users")
        let document = dbCollection.document(self.id)
        document.getDocument { [weak self](snapshot, error) in
            if let doc = snapshot {
                doc.data().map { info in
                    let realm = try! Realm()
                    realm.beginWrite()
                    if let name = info["name"] as? String {
                        self?.name = name
                    }
                    if let intro = info["intro"] as? String {
                        self?.introduce = intro
                    }                    
                    if let url = info["profileImageUrl"] as? String {
                        self?.profileImageURLfirebase = url
                    }
                    if let value = info["isDefaultProfile"] as? Bool {
                        self?.isDeleteProfileImage = value
                    }
                    self?.updateDt = Date()
                    try! realm.commitWrite()
                    complete()                    
                }
            }
        }
    }
    
    /** 사용자 정보를 firebase 로 업로드하여 갱신합니다.*/
    func updateData(complete:@escaping()->Void) {
        let dbCollection = Firestore.firestore().collection("users")
        let document = dbCollection.document(UserInfo.info!.id)
        let data:[String:Any] = [
            "name": self.name,
            "intro": self.introduce,
            "isDefaultProfile" : isDeleteProfileImage,
            "profileImageUrl" : profileImageURLfirebase
        ]
        
        document.updateData(data) {(error) in
            if let e = error {
                print(e.localizedDescription)
                document.setData(data, merge: true) { (error) in
                    if let e = error {
                        print(e.localizedDescription)
                    }
                    else {
                        complete()
                    }
                }
            }
            else {
                complete()
            }
        }
    }
    
    func logout() {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(self)
        try! realm.commitWrite()
        
        UIApplication.shared.windows.first?.rootViewController = LoginViewController.viewController
    }
}
