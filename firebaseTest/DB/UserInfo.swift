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
    /** 로그인 정보 */
    @objc dynamic var idToken                   : String    = ""
    @objc dynamic var accessToken               : String    = ""

    /** 이메일*/
    @objc dynamic var email                     : String    = ""
    /** 사용자 닉네임*/
    @objc dynamic var name                      : String    = ""
    /** 사용자의 자기소개*/
    @objc dynamic var introduce                 : String    = ""
    /** 프로필 이미지 (구글)*/
    @objc dynamic var profileImageURLgoogle     : String    = ""
    /** 업로드한 프로필 이미지*/
    @objc dynamic var profileImageURLfirebase   : String    = ""
    /** 최근 갱신 시각*/
    @objc dynamic var updateTimeIntervalSince1970: Double   = 0
    /** 마지막 대화 작성 시각*/
    @objc dynamic var lastTalkTimeIntervalSince1970: Double = 0

    /** 포인트*/
    @objc dynamic var point                     : Int       = 0

    /** 검색 거리 설정*/
    @objc dynamic var distanceForSearch         : Int       = Consts.DISTANCE_STORE_SEARCH

    /** 경험치*/
    @objc dynamic var exp                       : Int       = 0
    /** 레벨*/
    @objc dynamic var fcmID                     : String    = ""
    /** 멥 타입*/
    @objc dynamic var mapType                   : String    = "standard"
    
    /** 광고 시청 횟수*/
    @objc dynamic var count_of_ad               : Int      = 0
    /** 다른 사람의 글을 좋아요 한 횟수*/
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
            if lastTalkTimeIntervalSince1970 == 0 {
                return nil
            }
            return Date(timeIntervalSince1970: self.lastTalkTimeIntervalSince1970)
        }
        set {
            if let value = newValue {
                lastTalkTimeIntervalSince1970 = value.timeIntervalSince1970
            } else {
                lastTalkTimeIntervalSince1970 = 0
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
    

    static func createUser(
        email:String,
        name:String,
        searchDistance:Int,
        mapType:String,
        profileImage:UIImage?,
        googleProfileUrl:String?,
        complete:@escaping(_ isSucess:Bool)->Void) {
        
        func create(fileUrl:URL?) {
            let user = Firestore.firestore().collection(FSCollectionName.USERS).document(email)
            var data:[String:Any] = [
                "id":email,
                "email":email,
                "name":name,
                "searchDistance":searchDistance,
                "mapType":mapType,
            ]
            if let url = googleProfileUrl {
                data["googleProfileUrl"] = url
            }
            if let url = fileUrl {
                data["profileImageURLfirebase"] = url
            }
            user.setData(data) { (error) in
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(UserInfo.self, value: data, update: .all)
                try! realm.commitWrite()
                complete(error == nil)
            }

        }
        
        let fileUploadURL = "\(FSCollectionName.STORAGE_PROFILE_IMAGE)"
        if let image = profileImage {
            if let data = image.af.imageAspectScaled(toFit: CGSize(width: 500, height: 500)).jpegData(compressionQuality: 0.7) {
                FirebaseStorageHelper().uploadImage(withData: data, contentType: "image/jpeg", uploadURL: fileUploadURL) { (url) in
                    create(fileUrl: url)
                }
            }
        } else {
            create(fileUrl: nil)
        }
    }
    
    func updateToken(idToken:String,accessToken:String) {
        let realm = try! Realm()
        realm.beginWrite()
        self.idToken = idToken
        self.accessToken = accessToken
        try! realm.commitWrite()
    }
    
    
    /** firebase 에서 데이터를 받아와서 자신의 사용자 정보를 갱신합니다.*/
    func syncData(complete:@escaping(_ isNew:Bool)->Void) {
        let dbCollection = Firestore.firestore().collection(FSCollectionName.USERS)
        let document = dbCollection.document(self.email)
        
        document.getDocument { (snapshot, error) in
            if let doc = snapshot {
                if doc.data()?.count == 0 || doc.data() == nil {
                    complete(true)
                    return
                }
                doc.data().map { info in
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.create(UserInfo.self, value: info, update: .modified)
                    try! realm.commitWrite()
                    complete(false)
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
            .sorted(byKeyPath: "updateTimeIntervalSince1970") {
            if let email = UserInfo.info?.email {
                users  = users.filter("email != %@", email)
            }
            if let lastUser = users.last {
                query = dbCollection.whereField("updateTimeIntervalSince1970", isGreaterThan: lastUser.updateTimeIntervalSince1970)
            }
        }
                
        query
            .getDocuments { (snapShot, error) in
                let realm = try! Realm()
                realm.beginWrite()
                for doc in snapShot?.documents ?? [] {
                    let info = doc.data()
                    realm.create(UserInfo.self, value: info, update: .all)
                }
                try! realm.commitWrite()
                debugPrint("사용자 정보 갱신 : \(snapShot?.documents.count ?? 0)")
                getOtherUserComplete()
        }
    }
    
    /** 사용자 정보 가져오기*/
    static func getUserInfo(id:String,complete:@escaping(_ isSucess:Bool)->Void) {
        let dbCollection = Firestore.firestore().collection(FSCollectionName.USERS)
        let document = dbCollection.document(id)
        document.getDocument { (snapShot, error) in
            if let data = snapShot?.data() {
                let realm = try? Realm()
                realm?.beginWrite()
                realm?.create(UserInfo.self, value: data, update: .all)
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
            "introduce": self.introduce,
            "isDeleteProfileImage" : isDeleteProfileImage,
            "profileImageURLfirebase" : profileImageURLfirebase,
            "profileImageURLgoogle" : profileImageURLgoogle,
            "updateTimeIntervalSince1970" : self.updateTimeIntervalSince1970,
            "lastTalkTimeIntervalSince1970" : self.lastTalkTimeIntervalSince1970,
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
            self.updateTimeIntervalSince1970 = Date().timeIntervalSince1970
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
            .filter("creatorId = %@ && gameResultBase64encodingSting != %@ && regTimeIntervalSince1970 > %@"
                    , self.id
                    , ""
                    , Date.midnightTodayTime.timeIntervalSince1970
                    )
            .count
    }
    
    
    func updateLastTalkTime(timeInterval:Double = Date().timeIntervalSince1970, complete:@escaping(_ isSucess:Bool)->Void) {
        let userInfo = Firestore.firestore().collection(FSCollectionName.USERS).document(self.id)
        let userId = self.id
        let data:[String:Any] = [
            "id":userId,
            "lastTalkTimeIntervalSince1970": timeInterval
        ]
        userInfo.updateData(data) { (err) in
            if err == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(UserInfo.self, value: data, update: .modified)
                try! realm.commitWrite()
            }
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
                            model.updateTimeIntervalSince1970 = now.timeIntervalSince1970
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
    
    func getTalkList(complete:@escaping(_ isSucess:Bool)->Void) {
        Firestore.firestore().collection(FSCollectionName.TALKS)
            .whereField("creator_id", isEqualTo: self.id)
            .getDocuments { (snapshot, error) in
                if let data = snapshot {
                    var newModels:[Object] = []
                    let realm = try! Realm()
                    realm.beginWrite()
                    for documant in data.documents {
                        let data = documant.data()
                        realm.create(TalkModel.self, value: data, update: .all)
                    }
                    try! realm.commitWrite()

                    debugPrint("대화 이력 검색 \(newModels.count)건")
                    if newModels.count > 0 {
                        if let realm = try? Realm() {
                            realm.beginWrite()
                            realm.add(newModels, update: .all)
                            try? realm.commitWrite()
                        }
                    }
                    complete(true)
                    return
                }
                complete(false)
        }
    }
}
