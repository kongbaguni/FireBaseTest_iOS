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
import MapKit

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
    /** 멥 타입*/
    @objc dynamic var mapType                   : String    = "standard"
    
    /** 광고 시청 횟수*/
    @objc dynamic var count_of_ad               : Int      = 0
    /** 좋아요 받은 횟수*/
    @objc dynamic var count_of_like             : Int      = 0
    /** 게임 플레이한 횟수*/
    @objc dynamic var count_of_gamePlay         : Int      = 0
    /** 재고 리포트 성공 횟수*/
    @objc dynamic var count_of_report_stock     : Int      = 0
    /** 게임에서 잃은 포인트 총합*/
    @objc dynamic var sum_points_of_gameLose    : Int      = 0
    /** 게임에서 얻은 포인트 총합*/
    @objc dynamic var sum_points_of_gameWin     : Int      = 0
    enum MapType : String, CaseIterable {
        case standard = "standard"
        case satellite = "satellite"
        case hybrid = "hybrid"
        case satelliteFlyover = "satelliteFlyover"
        case hybridFlyover = "hybridFlyover"
        case mutedStandard = "mutedStandard"
        var mapTypeValue:MKMapType {
            get {
                switch self {
                case .standard:
                    return MKMapType.standard
                case .satellite:
                    return MKMapType.satellite
                case .hybrid:
                    return MKMapType.hybrid
                case .satelliteFlyover:
                    return MKMapType.satelliteFlyover
                case .mutedStandard:
                    return MKMapType.mutedStandard
                case .hybridFlyover:
                    return MKMapType.hybridFlyover
                }
            }
        }
    }
    
    var mapTypeValue : MapType {
        get {
            MapType(rawValue: mapType) ?? .standard
        }
        set {
            mapType = newValue.rawValue
        }
    }
    
    var level:Int {
        return Exp(exp).level
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
        count_of_report_stock = info["count_of_report_stock"] as? Int ?? 0
        count_of_ad = info["count_of_ad"] as? Int ?? 0
        count_of_like = info["count_of_like"] as? Int ?? 0
        count_of_gamePlay = info["count_of_gamePlay"] as? Int ?? 0
        sum_points_of_gameLose = info["sum_points_of_gameLose"] as? Int ?? 0
        sum_points_of_gameWin = info["sum_points_of_gameWin"] as? Int ?? 0
        mapType = info["mapType"] as? String ?? "standard"
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
        if UserInfo.info == nil {
            getOtherUserComplete()
            return
        }
        
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
            "mapType" : mapType,
            "sum_points_of_gameWin":sum_points_of_gameWin,
            "sum_points_of_gameLose":sum_points_of_gameLose,
            "count_of_gamePlay":count_of_gamePlay,
            "count_of_like":count_of_like,
            "count_of_ad":count_of_ad,
            "count_of_report_stock" : count_of_report_stock,
            "isAnonymousInventorfrffyReport" : false //isAnonymousInventoryReport,
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
            self.updateDt = Date()
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
        return Exp(exp).prevLevelExp
    }
    /** 다음 레벨까지 경험치*/
    var nextLevelupExp:Int {
        return Exp(exp).nextLevelupExp
    }
    
    enum RankingType:String, CaseIterable {
        case sum_points_of_gameWin = "sum_points_of_gameWin"
        case sum_points_of_gameLose = "sum_points_of_gameLose"
        case count_of_report_stock = "count_of_report_stock"
        case count_of_gamePlay = "count_of_gamePlay"
        case count_of_like = "count_of_like"
        case count_of_ad = "count_of_ad"
        case point = "point"
        case exp = "exp"
        static var withOutGameValues:[RankingType] {
            return [.count_of_report_stock, .count_of_ad, .count_of_like, .point, .exp]
        }
    }
    /** 랭킹 계산 위한 프로퍼티 갱신.
     주의: 포인트와 경험치는 여기서 갱신하지 않습니다.*/
    func updateForRanking(type:RankingType, addValue:Int, complete:@escaping(_ sucess:Bool)->Void) {
        let id = self.id
        let userInfo = Firestore.firestore().collection(FSCollectionName.USERS).document(self.id)
        userInfo.getDocument { (snapshot, error) in
            let now = Date()
            if let data = snapshot?.data() {
                if let value = data[type.rawValue] as? Int {
                    let newValue = value + addValue
                    userInfo.updateData([
                        type.rawValue : newValue
                        , "updateTimeIntervalSince1970" : now.timeIntervalSince1970
                    ]) { (error) in
                        let realm = try! Realm()
                        if let model = realm.object(ofType: UserInfo.self, forPrimaryKey: id) {
                            realm.beginWrite()
                            switch type {
                            case .count_of_report_stock:
                                model.count_of_report_stock = newValue
                            case .sum_points_of_gameWin:
                                model.sum_points_of_gameWin = newValue
                            case .sum_points_of_gameLose:
                                model.sum_points_of_gameLose = newValue
                            case .count_of_gamePlay:
                                model.count_of_gamePlay = newValue
                            case .count_of_like:
                                model.count_of_like = newValue
                            case .count_of_ad:
                                model.count_of_ad = newValue
                            default:
                                break
                            }
                            model.updateDt = now
                            try! realm.commitWrite()
                        }
                        complete(error == nil)
                    }
                }
            } else {
                complete(false)
            }
        }
//        "sum_points_of_gameWin":sum_points_of_gameWin,
//                 "sum_points_of_gameLose":sum_points_of_gameLose,
//                 "count_of_gamePlay":count_of_gamePlay,
//                 "count_of_like":count_of_like,
//                 "count_of_ad":count_of_ad,
    }
}
