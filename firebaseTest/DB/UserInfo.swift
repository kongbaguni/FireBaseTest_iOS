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
    var id:String {
        return email
    }
    
    @objc dynamic var email                     : String    = ""
    @objc dynamic var name                      : String    = ""
    @objc dynamic var introduce                 : String    = ""
    @objc dynamic var profileImageURLgoogle     : String    = ""
    @objc dynamic var profileImageURLfirebase   : String    = ""
    @objc dynamic var idToken                   : String    = ""
    @objc dynamic var accessToken               : String    = ""
    @objc dynamic var updateDt                  : Date      = Date()
    /** 프로필 이미지 사용하지 않을 경우 true*/
    @objc dynamic var _lastTalkDt               : Date      = Date(timeIntervalSince1970: 0)
    @objc dynamic var point                     : Int       = 0
    @objc dynamic var distanceForSearch         : Int       = Consts.DISTANCE_STORE_SEARCH
    var lastTalkDt:Date? {
        get {
            if _lastTalkDt == Date(timeIntervalSince1970: 0) {
                return nil
            }
            return _lastTalkDt
        }
        set {
            if let value = newValue {
                _lastTalkDt = value
            } else {
                _lastTalkDt = Date(timeIntervalSince1970: 0)
            }
        }
    }
    
    var lastTalkTimeInterval:Double? {
        get {
            return lastTalkDt?.timeIntervalSince1970
        }
        set {
            if let value = newValue {
                lastTalkDt = Date(timeIntervalSince1970: TimeInterval(value))
            }
        }
    }
    
    
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
        return "email"
    }
    
    /** firebase 에서 데이터를 받아와서 사용자 정보를 갱신합니다.*/
    func syncData(syncAll:Bool = true,complete:@escaping(_ isNew:Bool)->Void) {
        let dbCollection = Firestore.firestore().collection("users")
        let document = dbCollection.document(self.email)
        let userId = self.id
        var isNew = false
        document.getDocument { (snapshot, error) in
            if let doc = snapshot {
                var count = 0
                doc.data().map { info in
                    let realm = try! Realm()
                    if let uinfo = realm.object(ofType: UserInfo.self, forPrimaryKey: userId) {
                        realm.beginWrite()
                        if let name = info["name"] as? String {
                            uinfo.name = name
                        }
                        if let intro = info["intro"] as? String {
                            uinfo.introduce = intro
                        }
                        if let url = info["profileImageUrl"] as? String {
                            uinfo.profileImageURLfirebase = url
                        }
                        if let value = info["isDefaultProfile"] as? Bool {
                            uinfo.isDeleteProfileImage = value
                        }
                        if let url = info["profileImageUrlGoogle"] as? String {
                            uinfo.profileImageURLgoogle = url
                        }
                        if let lastTalkTime = info["lastTalkTimeIntervalSince1970"] as? Double {
                            uinfo.lastTalkTimeInterval = lastTalkTime
                        }
                        if let value = info["updateTimeIntervalSince1970"] as? Double {
                            uinfo.updateDt = Date(timeIntervalSince1970: TimeInterval(value))
                        }
                        if let point = info["point"] as? Int {
                            uinfo.point = point
                        }
                        if let value = info["distanceForSearch"] as? Int {
                            uinfo.distanceForSearch = value
                        }
                        try! realm.commitWrite()
                    }
                    count += 1
                }
                isNew = count == 0
                if syncAll == false {
                    complete(isNew)
                }
            }
        }
        if syncAll == false {
            return
        }
        // 다른 유저 정보 가져오기
        dbCollection
            .whereField("lastTalkTimeIntervalSince1970", isGreaterThan: Date().timeIntervalSince1970 - Consts.LIMIT_TALK_TIME_INTERVAL)
            .getDocuments { (snapShot, error) in
            var newUsers:[UserInfo] = []
            for doc in snapShot?.documents ?? [] {
                let info = doc.data()
                guard let name = info["name"] as? String,
                    let email = info["email"] as? String else {
                        continue
                }
                if email == self.email {
                    continue
                }
                let intro = info["intro"] as? String ?? ""

                let isDefaultProfile = info["isDefaultProfile"] as? Bool ?? false
                let profileImageUrl = info["profileImageUrl"] as? String ?? ""
                let profileimageUrlGoogle = info["profileImageUrlGoogle"] as? String ?? ""
                let point = info["point"] as? Int ?? 0
                let distanceForSearch = info["distanceForSearch"] as? Int ?? Consts.DISTANCE_STORE_SEARCH

                let userInfo = UserInfo()
                userInfo.email = email
                userInfo.name = name
                userInfo.introduce = intro
                userInfo.isDeleteProfileImage = isDefaultProfile
                userInfo.profileImageURLfirebase = profileImageUrl
                userInfo.profileImageURLgoogle = profileimageUrlGoogle
                userInfo.distanceForSearch = distanceForSearch
                userInfo.point = point
                if let lastTalkTime = info["lastTalkTimeIntervalSince1970"] as? Double {
                    userInfo.lastTalkTimeInterval = lastTalkTime
                }

                newUsers.append(userInfo)
            }
            if newUsers.count > 0 {
                let realm = try! Realm()
                realm.beginWrite()
                realm.add(newUsers,update: .all)
                try! realm.commitWrite()
            }
            complete(isNew)
        }
    }
    
    /** 사용자 정보를 firebase 로 업로드하여 갱신합니다.*/
    func updateData(complete:@escaping(_ isSucess:Bool)->Void) {
        let dbCollection = Firestore.firestore().collection("users")
        let document = dbCollection.document(UserInfo.info!.email)
        let data:[String:Any] = [            
            "name": self.name,
            "email" : self.email,
            "intro": self.introduce,
            "isDefaultProfile" : isDeleteProfileImage,
            "profileImageUrl" : profileImageURLfirebase,
            "profileImageUrlGoogle" : profileImageURLgoogle,
            "updateTimeIntervalSince1970" : self.updateDt.timeIntervalSince1970,
            "distanceForSearch" : distanceForSearch,
            "point" : point
        ]
        
        document.updateData(data) {(error) in
            if let e = error {
                print(e.localizedDescription)
                document.setData(data, merge: true) { (error) in
                    if let e = error {
                        print(e.localizedDescription)
                        complete(false)
                    }
                    else {
                        complete(true)
                    }
                }
            }
            else {
                complete(true)
            }
        }
    }
    
    func logout() {
        UIApplication.shared.windows.first?.rootViewController = UIViewController()
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
        
        UIApplication.shared.windows.first?.rootViewController = LoginViewController.viewController
    }
    
    func addPoint(point:Int, complete:@escaping(_ isSucess:Bool)->Void) {
        func addPoint(point:Int) {
            let realm = try! Realm()
            realm.beginWrite()
            self.point += point
            try! realm.commitWrite()
        }
        addPoint(point: point)
        updateData { isSucess in
            if isSucess {
                complete(true)
            } else {
                addPoint(point: -point)
                complete(false)
            }
        }
        
    }
}
