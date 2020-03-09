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
    @objc dynamic var id                        : String    = ""
    @objc dynamic var email                     : String    = "" {
        didSet {
            id = email.sha512
        }
    }
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
        return try! Realm().objects(UserInfo.self).filter("idToken != %@ && accessToken != %@", "", "").first
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
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    /** firebase 에서 데이터를 받아와서 사용자 정보를 갱신합니다.*/
    func syncData(complete:@escaping(_ isNew:Bool)->Void) {
        let dbCollection = Firestore.firestore().collection("users")
        let document = dbCollection.document(self.id)
        document.getDocument { [weak self](snapshot, error) in
            if let doc = snapshot {
                var count = 0
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
                    if let url = info["profileImageUrlGoogle"] as? String {
                        self?.profileImageURLgoogle = url
                    }
                    self?.updateDt = Date()
                    try! realm.commitWrite()
                    count += 1
                }
                complete(count == 0)
            }
        }
        // 다른 유저 정보 가져오기
        dbCollection
            .whereField("lastTalkTimeIntervalSince1970", isGreaterThan: Date().timeIntervalSince1970 - Consts.LIMIT_TALK_TIME_INTERVAL)
            .getDocuments { (snapShot, error) in
            var newUsers:[UserInfo] = []
            for doc in snapShot?.documents ?? [] {
                let info = doc.data()
                guard let id = info["id"] as? String,
                    let name = info["name"] as? String,
                    let email = info["email"] as? String else {
                        continue
                }
                if id == self.id {
                    continue
                }
                let intro = info["into"] as? String ?? ""

                let isDefaultProfile = info["isDefaultProfile"] as? Bool ?? false
                let profileImageUrl = info["profileImageUrl"] as? String ?? ""
                let profileimageUrlGoogle = info["profileImageUrlGoogle"] as? String ?? ""
                
                let userInfo = UserInfo()
                userInfo.email = email
                userInfo.name = name
                userInfo.introduce = intro
                userInfo.isDeleteProfileImage = isDefaultProfile
                userInfo.profileImageURLfirebase = profileImageUrl
                userInfo.profileImageURLgoogle = profileimageUrlGoogle
                newUsers.append(userInfo)
            }
            if newUsers.count > 0 {
                let realm = try! Realm()
                realm.beginWrite()
                realm.add(newUsers,update: .all)
                try! realm.commitWrite()
            }
        }
    }
    
    /** 사용자 정보를 firebase 로 업로드하여 갱신합니다.*/
    func updateData(complete:@escaping()->Void) {
        let dbCollection = Firestore.firestore().collection("users")
        let document = dbCollection.document(UserInfo.info!.id)
        let data:[String:Any] = [
            "id" : self.id,
            "name": self.name,
            "email" : self.email,
            "intro": self.introduce,
            "isDefaultProfile" : isDeleteProfileImage,
            "profileImageUrl" : profileImageURLfirebase,
            "profileImageUrlGoogle" : profileImageURLgoogle
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
        realm.deleteAll()
        try! realm.commitWrite()
        
        UIApplication.shared.windows.first?.rootViewController = LoginViewController.viewController
    }
}
