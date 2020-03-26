//
//  TalkModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore
import CoreLocation

/** talk 수정이력 기록 위한 모델*/
class TextEditModel : Object {
    @objc dynamic var id:String = "" {
        didSet {
            if let str = imageUrl?.absoluteString {
                imageURLstr = str
            }
            _regDt = regDt
        }
    }
    @objc dynamic var imageURLstr:String = ""
    @objc dynamic var _regDt:Date = Date(timeIntervalSince1970: 0)
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func setData(text:String,imageURL:String?) {
        let imgUrl:String = imageURL ?? "none"
        id = "\(text)[__##__]\(imgUrl)[__##__]\(UUID().uuidString)[__##__]\(Date().timeIntervalSince1970)"
    }
    
    var regDt:Date {
        let str = id.components(separatedBy: "[__##__]").last
        let interval = TimeInterval(NSString(string: str!).doubleValue)
        return Date(timeIntervalSince1970: interval)
    }
        
    var text:String {
        return id.components(separatedBy: "[__##__]").first!
    }
    
    var imageUrl:URL? {
        if id.components(separatedBy: "[__##__]").count < 2 {
            return nil
        }
        let str = id.components(separatedBy: "[__##__]")[1]
        if str == "none" || str == "deleted" {
            return nil
        }
        return URL(string: str)
    }
    
    var isImageDeleted:Bool {
        if id.components(separatedBy: "[__##__]").count < 2 {
            return false
        }
        let str = id.components(separatedBy: "[__##__]")[1]
        if str == "deleted" {
            return true
        }
        return false
    }
    
    
}

class TalkModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var text:String = "" {
        didSet {
            if textForSearch == "" {
                textForSearch = text
            }
        }
    }
    @objc dynamic var creatorId:String = ""
    @objc dynamic var lng:Double = UserDefaults.standard.lastMyCoordinate?.longitude ?? 0
    @objc dynamic var lat:Double = UserDefaults.standard.lastMyCoordinate?.latitude ?? 0
    @objc dynamic var imageUrl:String = ""
    
    /** 최종 이미지 URL 구하기.*/
    var imageURL:URL? {
        if editList.count == 0 {
            return URL(string: imageUrl)
        }
        if let url = editList.last?.imageUrl {
            return url
        }
        return nil
    }
    
    @objc dynamic var holdemResultBase64encodingSting:String = ""
    var holdemResult:HoldemResult? {
        get {
            HoldemResult.makeResult(base64EncodedString: holdemResultBase64encodingSting)
        }
        set {
            if let value = newValue?.jsonBase64EncodedString {
                holdemResultBase64encodingSting = value
            }
        }
    }
    
    @objc dynamic var cards:String = ""
    
    var cardSet:CardSet?  {
        set {
            if let set = newValue {
                cards = set.stringValue
            } else {
                cards = ""
            }
        }
        get {
            return CardSet.makeCardsWithString(string: cards) 
        }
    }
    @objc dynamic var delarCards:String = ""
    var delarCardSet:CardSet?  {
        set {
            if let set = newValue {
                delarCards = set.stringValue
            } else {
                delarCards = ""
            }
        }
        get {
            return CardSet.makeCardsWithString(string: delarCards)
        }
    }
    @objc dynamic var bettingPoint:Int = 0

    
    var cordinate:CLLocationCoordinate2D? {
        if lat != 0 && lng != 0 {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        return nil
    }
    
    var location:CLLocation? {
        if lat != 0 && lng != 0 {
            return CLLocation(latitude: lat, longitude: lng)
        }
        return nil
    }

    // 검색 위한 필드
    @objc dynamic var textForSearch:String = ""

    @objc dynamic var regTimeIntervalSince1970:Double = 0 {
        didSet {
            if modifiedTimeIntervalSince1970 == 0 {
                modifiedTimeIntervalSince1970 = regTimeIntervalSince1970
            }
        }
    }
    @objc dynamic var modifiedTimeIntervalSince1970:Double = 0
    let likes = List<LikeModel>()
    let editList = List<TextEditModel>()
   
    func insertEdit(data:TextEditModel) {
        editList.append(data)
        textForSearch = data.text
    }
    
    func loadData(id:String, text:String, creatorId:String, regTimeIntervalSince1970:Double) {
        self.id = id
        self.text = text
        self.creatorId = creatorId
        self.regTimeIntervalSince1970 = regTimeIntervalSince1970
    }
    
    var regDt:Date {
        return Date(timeIntervalSince1970: regTimeIntervalSince1970)
    }
    
    
    var modifiedDt:Date? {
        if modifiedTimeIntervalSince1970 == 0 {
            return nil
        }
        return Date(timeIntervalSince1970: modifiedTimeIntervalSince1970)
    }
    
    var modifiedDtStr:String? {
        if let date = modifiedDt {
            return  DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        }
        return nil
    }
    
    override static func primaryKey() -> String? {
           return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["creatorId", "cards"]
    }
    
    /** fireBaseStore 에 생성된 데이터 갱신하기*/
    func update(complete:@escaping(_ isSucess:Bool)->Void) {
        if text.isEmpty {
            return
        }
        var likeIds:[String] = []
        for like in likes {
            likeIds.append(like.id)
        }
        
        var editTexts:[String] = []
        for edit in editList {
            editTexts.append(edit.id)
        }
                
        let data:[String:Any] = [
            "documentId":id,
            "regTimeIntervalSince1970":regTimeIntervalSince1970,
            "modifiedTimeIntervalSince1970":modifiedTimeIntervalSince1970,
            "creator_id":creatorId,
            "talk":text,
            "likeIds":likeIds,
            "editTextIds":editTexts,
            "lat":lat,
            "lng":lng,
            "cards":cards,
            "delarCards":delarCards,
            "bettingPoint":bettingPoint,
            "holdemResultBase64encodingSting" : holdemResultBase64encodingSting,
            "imageUrl":imageUrl
        ]
        
        let collection = Firestore.firestore().collection(FSCollectionName.TALKS)
        let document = collection.document(id)
        document.setData(data, merge: true) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.add(self, update: .all)
                try! realm.commitWrite()
                UserInfo.info?.updateLastTalkTime(timeInterval: self.modifiedTimeIntervalSince1970, complete: { (isSucess) in                
                    
                })
                complete(true)
                return
            }
            complete(false)
        }
        
    }
    
    static func syncDatas(complete:@escaping()->Void) {
        let realm = try! Realm()
        var syncDt = Date.midnightTodayTime.timeIntervalSince1970
        if let lastTalk = realm.objects(TalkModel.self).sorted(byKeyPath: "modifiedTimeIntervalSince1970").last {
            if syncDt < lastTalk.regTimeIntervalSince1970 {
                syncDt = lastTalk.regTimeIntervalSince1970
            }
        }
        
        let collection = Firestore.firestore().collection(FSCollectionName.TALKS)
        collection
            .whereField("modifiedTimeIntervalSince1970", isGreaterThan: syncDt)
            .getDocuments { (shot, error) in
                guard let snap = shot else {
                    return
                }
                let realm = try! Realm()
                realm.beginWrite()
                print(snap.documents.count)
                for doc in snap.documents {
                    let data = doc.data()
                    let model = TalkModel()
                    if model.loadData(data: data) {
                        realm.add(model, update: .all)
                    }
                }
                try! realm.commitWrite()
                complete()
        }
        
    }
    
    var creator:UserInfo? {
        return try! Realm().object(ofType: UserInfo.self, forPrimaryKey:creatorId)
    }
    
    var isLike:Bool {
        guard let userId = UserInfo.info?.id else {
            return false
        }
        if self.likes.filter("creatorId == %@",userId).first != nil {
            return true
        } else {
            return false
        }
    }
    
    func toggleLike(){
        guard let userId = UserInfo.info?.id else {
            return
        }
        let realm = try! Realm()
        realm.beginWrite()
        var isLike = false
        
        if let like = self.likes.filter("creatorId == %@",userId).first {
            realm.delete(like)
        } else {
            isLike = true
            let likeModel = LikeModel()
            likeModel.set(creatorId: userId, targetTalkId: self.id)
            self.likes.append(likeModel)
            realm.add(likeModel,update: .all)
            debugPrint("좋아요 : \(likes.count) 개")
        }
        try! realm.commitWrite()

        if creatorId != UserInfo.info?.id {
            UserInfo.info?.updateForRanking(type: .count_of_like, addValue: isLike ? 1 : -1) { (sucess) in
                
            }
        } 
    }
    
    func loadData(data:[String:Any])->Bool {
        if let regTimeIntervalSince1970 = data["regTimeIntervalSince1970"] as? Double,
            let modifiedTimeIntervalSince1970 = data["modifiedTimeIntervalSince1970"] as? Double,
            let creatorId = data["creator_id"] as? String,
            let text = data["talk"] as? String,
            let id = data["documentId"] as? String {

            imageUrl = data["imageUrl"] as? String ?? ""
            lng = data["lng"] as? Double ?? 0
            lat = data["lat"] as? Double ?? 0
            self.regTimeIntervalSince1970 = regTimeIntervalSince1970
            self.modifiedTimeIntervalSince1970 = modifiedTimeIntervalSince1970
            self.creatorId = creatorId
            self.text = text
            self.id = id
            cards = data["cards"] as? String ?? ""
            delarCards = data["delarCards"] as? String ?? ""
            bettingPoint = data["bettingPoint"] as? Int ?? 0
            holdemResultBase64encodingSting = data["holdemResultBase64encodingSting"] as? String ?? ""
            if let likeIds = data["likeIds"] as? [String] {
                var cnt = 0
                for likeId in likeIds {
                    let likeModel = LikeModel()
                    likeModel.id = likeId
                    cnt += 1
                    likes.append(likeModel)
                }
            }
            
            editList.removeAll()
            if let editTextIds = data["editTextIds"] as? [String] {
                for id in editTextIds {
                    let edit = TextEditModel()
                    edit.id = id
                    insertEdit(data: edit)
                }
            }
            return true
        }
        return false
    }
    
    func delete(complete:@escaping(_ sucess:Bool)->Void) {
        GameManager.shared.usePoint(point: AdminOptions.shared.pointUseDeleteTalk) { (sucess) in
            if sucess {
                Firestore.firestore().collection(FSCollectionName.TALKS).document(self.id).delete { (error) in
                    if error == nil {
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.delete(self)
                        try! realm.commitWrite()
                        Toast.makeToast(message: "delete talk sucess".localized)
                        complete(true)
                    }
                    else {
                        complete(false)
                    }
                }
            }
            else {
                complete(false)
            }

        }
    }
}
