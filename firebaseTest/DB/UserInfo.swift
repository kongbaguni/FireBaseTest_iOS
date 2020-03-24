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
import FirebaseAuth

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
    /** 경험치*/
    @objc dynamic var exp                       : Int       = 0
    /** 레벨*/
    @objc dynamic var fcmID                     : String    = ""
    var level:Int {
        var e = self.exp
        var level = 0
        while e > 0 {
            e -= (AdminOptions.shared.levelup_req_exp_base + level * AdminOptions.shared.levelup_req_exp_plus)
            level += 1
        }
        return level
    }
    /** 익명으로 마스크재고 보고하기*/
    @objc dynamic var isAnonymousInventoryReport : Bool = false

    /** 사용자 정보 동기화로 전송받은 정보인가? */
    @objc dynamic var isFromUserInfoSync        :Bool = false
    var levelStrValue:String {
        return level.decimalForamtString
    }
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
        if let info = try? Realm().objects(UserInfo.self).filter("idToken != %@ && accessToken != %@", "", "").first {
            if info.isInvalidated {
                return nil
            }
            return info
        }
        return nil
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
    

    
    func setData(info:[String:Any]) {
        if let name = info["name"] as? String {
            self.name = name
        }
        if let intro = info["intro"] as? String {
            self.introduce = intro
        }
        if let url = info["profileImageUrl"] as? String {
            self.profileImageURLfirebase = url
        }
        if let value = info["isDefaultProfile"] as? Bool {
            self.isDeleteProfileImage = value
        }
        if let url = info["profileImageUrlGoogle"] as? String {
            self.profileImageURLgoogle = url
        }
        if let lastTalkTime = info["lastTalkTimeIntervalSince1970"] as? Double {
            self.lastTalkTimeInterval = lastTalkTime
        }
        if let id = info["fmcID"] as? String {
            self.fcmID = id
        }
//        isAnonymousInventoryReport = info["isAnonymousInventoryReport"] as? Bool ?? false
        isAnonymousInventoryReport = false
        updateDt = Date(timeIntervalSince1970: (info["updateTimeIntervalSince1970"] as? Double ?? 0))
        point = info["point"] as? Int ?? 0
        distanceForSearch = info["distanceForSearch"] as? Int ?? Consts.DISTANCE_STORE_SEARCH
        exp = info["exp"] as? Int ?? 0
    }
    
    /** firebase 에서 데이터를 받아와서 자신의 사용자 정보를 갱신합니다.*/
    func syncData(complete:@escaping(_ isNew:Bool)->Void) {
        let dbCollection = Firestore.firestore().collection(FSCollectionName.USERS)
        let document = dbCollection.document(self.email)
        let userId = self.id
        
        document.getDocument { (snapshot, error) in
            if let doc = snapshot {
                if doc.data()?.count == 0 || doc.data() == nil {
                    complete(true)
                    return
                }
                doc.data().map { info in
                    let realm = try! Realm()
                    if let uinfo = realm.object(ofType: UserInfo.self, forPrimaryKey: userId) {
                        realm.beginWrite()
                        uinfo.setData(info: info)
                        try! realm.commitWrite()
                        complete(false)
                    }
                }
            }
        }
    }
    /** 사용자 정보 동기화 (최근 7일간 글을 작성한 이력이 있는 사용자만 긁어옴*/
    static func syncUserInfo(getOtherUserComplete:@escaping()->Void) {
        let dbCollection = Firestore.firestore().collection(FSCollectionName.USERS)
        var query =
            dbCollection
                .whereField("lastTalkTimeIntervalSince1970", isGreaterThan: Date.getMidnightTime(beforDay: 7).timeIntervalSince1970)
        
        if var users = try? Realm().objects(UserInfo.self)
            .filter("isFromUserInfoSync = %@", true)
            .sorted(byKeyPath: "updateDt") {
            if let email = UserInfo.info?.email {
                users  = users.filter("email != %@", email)
            }
            if let lastUser = users.last {
                query = dbCollection.whereField("updateTimeIntervalSince1970", isGreaterThan: lastUser.updateDt.timeIntervalSince1970)
            }
        }
                
        query
            .getDocuments { (snapShot, error) in
                var newUsers:[UserInfo] = []
                for doc in snapShot?.documents ?? [] {
                    let info = doc.data()
                    guard let email = info["email"] as? String else {
                        continue
                    }
                    if email == UserInfo.info?.email {
                        continue
                    }
                    let userInfo = UserInfo()
                    userInfo.email = email
                    userInfo.setData(info: info)
                    userInfo.isFromUserInfoSync = true
                    if let lastTalkTime = info["lastTalkTimeIntervalSince1970"] as? Double {
                        userInfo.lastTalkTimeInterval = lastTalkTime
                    }
                    
                    newUsers.append(userInfo)
                }
                debugPrint("사용자 정보 갱신 : \(newUsers.count)")
                if newUsers.count > 0 {
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.add(newUsers,update: .all)
                    try! realm.commitWrite()
                }
                getOtherUserComplete()
        }
    }
    
    /** 사용자 정보 가져오기*/
    static func getUserInfo(id:String,complete:@escaping(_ isSucess:Bool)->Void) {
        let dbCollection = Firestore.firestore().collection(FSCollectionName.USERS)
        let document = dbCollection.document(id)
        document.getDocument { (snapShot, error) in
            if let data = snapShot?.data() , let email = data["email"] as? String  {
                let realm = try? Realm()
                let user = UserInfo()
                user.email = email
                user.setData(info: data)
                realm?.beginWrite()
                realm?.add(user, update: .all)
                try? realm?.commitWrite()
                complete(true)
                return
            }
            complete(false)
        }
    }
    
    /** 사용자 정보를 firebase 로 업로드하여 갱신합니다.*/
    func updateData(complete:@escaping(_ isSucess:Bool)->Void) {
        let dbCollection = Firestore.firestore().collection(FSCollectionName.USERS)
        let document = dbCollection.document(UserInfo.info!.email)
        let data:[String:Any] = [            
            "name": self.name,
            "email" : self.email,
            "intro": self.introduce,
            "isDefaultProfile" : isDeleteProfileImage,
            "profileImageUrl" : profileImageURLfirebase,
            "profileImageUrlGoogle" : profileImageURLgoogle,
            "updateTimeIntervalSince1970" : self.updateDt.timeIntervalSince1970,
            "lastTalkTimeIntervalSince1970" : self.updateDt.timeIntervalSince1970,
            "distanceForSearch" : distanceForSearch,
            "point" : point,
            "exp" : exp,
            "fcmID" : fcmID,
            "isAnonymousInventoryReport" : false //isAnonymousInventoryReport,
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
    
    func logout(isDeleteAll:Bool = false) {
        UIApplication.shared.rootViewController = UIViewController()
        
        let realm = try! Realm()
        realm.beginWrite()
        if isDeleteAll {
            realm.deleteAll()
        } else {
            UserInfo.info?.idToken = ""
            UserInfo.info?.accessToken = ""
        }
        try! realm.commitWrite()
        StoreModel.deleteAll()
        
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        
        UIApplication.shared.rootViewController = LoginViewController.viewController
    }
    
    func addPoint(point:Int, complete:@escaping(_ isSucess:Bool)->Void) {
        func addPoint(point:Int) {
            let realm = try! Realm()
            realm.beginWrite()
            self.point += point
            let oldLevel = level
            exp += abs(point)
            if oldLevel > level {
                NotificationCenter.default.post(name: .game_levelupNotification, object: level)
            }
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
    
    var todaysMyGameCount:Int {
        let realm = try! Realm()
        
        return realm.objects(TalkModel.self)
            .filter("creatorId = %@ && bettingPoint > %@ && regTimeIntervalSince1970 > %@"
                    , self.id
                    , 0
                    , Date.midnightTodayTime.timeIntervalSince1970
                    )
            .count
    }
    
    
    func updateLastTalkTime(timeInterval:Double = Date().timeIntervalSince1970, complete:@escaping(_ isSucess:Bool)->Void) {
        let userInfo = Firestore.firestore().collection(FSCollectionName.USERS).document(self.id)
        userInfo.updateData(["lastTalkTimeIntervalSince1970": timeInterval]) { (err) in
            complete(err == nil)
        }
    }
    
    /** 이전 레벨까지 경험치*/
    var prevLevelExp:Int {
        let level = self.level
        var exp = 0
        for i in 0..<level-1 {
            exp += AdminOptions.shared.levelup_req_exp_base + (AdminOptions.shared.levelup_req_exp_plus * i)
        }
        return exp
    }
    /** 다음 레벨까지 경험치*/
    var nextLevelupExp:Int {
        let level = self.level
        var exp = 0
        for i in 0...level-1 {
            exp += AdminOptions.shared.levelup_req_exp_base + (AdminOptions.shared.levelup_req_exp_plus * i)
        }
        return exp
    }
}
