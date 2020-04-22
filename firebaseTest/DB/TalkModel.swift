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

extension Notification.Name {
    /** 글 쓰기 관련 노티*/
    static let talkUpdateNotification = Notification.Name(rawValue: "talkUpdateNotification_observer")
}

/** talk 수정이력 기록 위한 모델*/
class TextEditModel : Object {
    @objc dynamic var id:String = ""
    @objc dynamic var text:String = ""
    @objc dynamic var imageUrlStr:String = ""
    @objc dynamic var regTimeIntervalSince1970:Double = 0
    @objc dynamic var lat:Double = 0
    @objc dynamic var lng:Double = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
extension TextEditModel {
    var regDt:Date {        
        return Date(timeIntervalSince1970: regTimeIntervalSince1970)
    }
    
    var isImageDeleted:Bool {
        return imageUrlStr == ""
    }
    
    var cordinate:CLLocationCoordinate2D? {
        if lat != 0 && lng != 0 {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        return nil
    }
    
    var imageUrl:URL? {
        if imageUrlStr.isEmpty {
            return nil
        }
        return URL(string: imageUrlStr)
    }
    
}

class TalkModel: Object {
    /** 프라이머리 키*/
    @objc dynamic var id:String = ""
    /** 대화 내용*/
    @objc dynamic var text:String = "" {
        didSet {
            if textForSearch == "" {
                textForSearch = text
            }
        }
    }
    /** 작성자*/
    @objc dynamic var creatorId:String = ""
    /** 위도*/
    @objc dynamic var lng:Double = UserDefaults.standard.lastMyCoordinate?.longitude ?? 0
    /** 경도*/
    @objc dynamic var lat:Double = UserDefaults.standard.lastMyCoordinate?.latitude ?? 0
    /** 첨부이미지 URL*/
    @objc dynamic var imageUrl:String = ""
    /** 게임결과 json Data 를  base64인코딩 한 문자열*/
    @objc dynamic var gameResultBase64encodingSting:String = ""
    /** 검색을 위한 text. 수정내역에서 가장 마지막 내용이 저장됨*/
    @objc dynamic var textForSearch:String = ""
    /** 삭제된 토크임*/
    @objc dynamic var isDeleted:Bool = false
    
    /** 등록시각 */
    @objc dynamic var regTimeIntervalSince1970:Double = 0 {
        didSet {
            if modifiedTimeIntervalSince1970 == 0 {
                modifiedTimeIntervalSince1970 = regTimeIntervalSince1970
            }
        }
    }
    /** 수정시각*/
    @objc dynamic var modifiedTimeIntervalSince1970:Double = 0
    
    @objc dynamic var readDetailCount:Int = 0
    /** 좋아요 목록*/
    let likes = List<LikeModel>()
    /** 수정이력*/
    let editList = List<TextEditModel>()
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["creatorId", "cards"]
    }
    
}


extension TalkModel {
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
    
    func toggleLike(complete toggleComplete:@escaping(_ isSucess:Bool)->Void){
        let creatorId = self.creatorId
        /** 글 쓴이의 유저정보*/
        let user = FS.store.collection(FSCollectionName.USERS).document(creatorId)
        let likeID = "\(UserInfo.info!.id) is like \(id)"
        
        func like(complete:@escaping(_ isLike:Bool?)->Void) {
            guard let userId = UserInfo.info?.id else {
                return
            }
            let talkId = id
            let now = Date().timeIntervalSince1970
            let doc = FS.store.collection(FSCollectionName.TALKS).document(talkId)
            doc.updateData(["modifiedTimeIntervalSince1970":now]) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    if let talkModel = realm.object(ofType: TalkModel.self, forPrimaryKey: talkId) {
                        realm.beginWrite()
                        talkModel.modifiedTimeIntervalSince1970 = now
                        try! realm.commitWrite()
                    }
                    
                    let collection = doc.collection("like")
                    collection.whereField("creatorId", isEqualTo: userId).getDocuments { (snapShot, error) in
                        if let data = snapShot {
                            if data.documents.count == 0 {
                                let likeId = "\(UUID().uuidString)\(userId)\(now)"
                                let likeData:[String:Any] = [
                                    "id":likeId,
                                    "creatorId":userId,
                                    "targetId":talkId,
                                    "regTimeIntervalSince1970":now
                                ]
                                collection.document(likeId).setData(likeData) { (error) in
                                    if error == nil {
                                        let realm = try! Realm()
                                        if let talk = realm.object(ofType: TalkModel.self, forPrimaryKey: talkId) {
                                            realm.beginWrite()
                                            let like = realm.create(LikeModel.self, value: likeData, update: .all)
                                            talk.likes.append(like)
                                            try! realm.commitWrite()
                                        }
                                        complete(true)
                                    }
                                    else {
                                        complete(nil)
                                    }
                                }
                            } else {
                                if let info = data.documents.first?.data() {
                                    let likeId = info["id"] as! String
                                    collection.document(likeId).delete { (error) in
                                        if error == nil {
                                            let realm = try! Realm()
                                            if let likeModel = realm.object(ofType: LikeModel.self, forPrimaryKey: likeId) {
                                                realm.beginWrite()
                                                realm.delete(likeModel)
                                                try! realm.commitWrite()
                                            }
                                            complete(false)
                                        } else {
                                            complete(nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    complete(nil)
                }
            }
        }
    
        func addLikeAtUserInfo(isLike:Bool,complete:@escaping(_ isSucess:Bool)->Void) {
            if creatorId == UserInfo.info?.id {
                complete(true)
                return
            }
            let like = user.collection("like").document(likeID)
            if isLike {
                like.setData(["value":likeID]) { (error) in
                    complete(error == nil)
                }
            } else {
                like.delete { (error) in
                    complete(error == nil)
                }
            }
        }
        
        func updateUserInfo(complete:@escaping(_ isSucess:Bool)->Void) {
            if creatorId == UserInfo.info?.id {
                complete(true)
                return
            }
            user.collection("like").getDocuments { (snapShot, error) in
                if let data = snapShot {
                    let count = data.documents.count
                    let data:[String:Any] = [
                        "id" : creatorId,
                        "count_of_recive_like" : count
                    ]
                    user.updateData(data) { (error) in
                        if error == nil {
                            let realm = try! Realm()
                            realm.beginWrite()
                            realm.create(UserInfo.self, value: data, update: .modified)
                            try! realm.commitWrite()
                        }
                        complete(error == nil)
                    }
                }
            }
        }
        
                
        like { (isLike) in
            if let value = isLike {
                toggleComplete(true)
                UserInfo.info?.updateForRanking(type: .count_of_like, addValue: value ? 1 : -1, complete: { (sucess) in
                    
                })
                addLikeAtUserInfo(isLike: value) { (sucess) in
                    updateUserInfo { (sucess) in
                    }
                }
            } else {
                toggleComplete(false)
            }
        }
    }
    
    var holdemResult:HoldemResult? {
        get {
            HoldemResult.makeResult(base64EncodedString: gameResultBase64encodingSting)
        }
        set {
            if let value = newValue?.jsonBase64EncodedString {
                gameResultBase64encodingSting = value
            }
        }
    }
    
    func delete(complete:@escaping(_ sucess:Bool)->Void) {
        let docId = self.id
        GameManager.shared.usePoint(point: AdminOptions.shared.pointUseDeleteTalk) { (sucess) in
            if sucess {
                let doc = FS.store.collection(FSCollectionName.TALKS).document(docId)
                let data:[String:Any] = [
                    "id" : docId,
                    "text":"",
                    "textForSearch":"",
                    "gameResultBase64encodingSting":"",
                    "modifiedTimeIntervalSince1970":Date().timeIntervalSince1970,
                    "isDeleted":true
                ]
                doc.updateData(data, completion: { (error) in
                    doc.collection("edit").getDocuments { (snapShot, error) in
                        for edit in snapShot?.documents ?? [] {
                            let id = edit.documentID
                            doc.collection("edit").document(id).delete()
                        }
                        let realm = try! Realm()
                        realm.beginWrite()
                        let model = realm.create(TalkModel.self, value: data, update: .modified)
                        model.editList.removeAll()
                        try! realm.commitWrite()
                        complete(true)
                    }
                })
            }
            else {
                complete(false)
            }
            
        }
    }
    
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
    
    func loadData(id:String, text:String, creatorId:String, regTimeIntervalSince1970:Double) {
        self.id = id
        self.text = text
        self.creatorId = creatorId
        self.regTimeIntervalSince1970 = regTimeIntervalSince1970
    }
    
    /** 글쓰기*/
    static func create(text:String, imageUrl:URL? = nil, gameResultBase64encodingString:String? = nil, complete:@escaping(_ documentId:String?)->Void) {
        guard let userId = UserInfo.info?.id else {
            complete(nil)
            return
        }
        let now = Date().timeIntervalSince1970
        let id = "\(userId)_\(now)\(UUID().uuidString)"
        let fileUploadURL = "\(FSCollectionName.STORAGE_TLAK_IMAGE)/\(userId)"
        
        func upload(uploadUrl:URL?) {
            var data:[String:Any] = [
                "id":id,
                "text":text,
                "creatorId":userId,
                "lng":UserDefaults.standard.lastMyCoordinate?.longitude ?? 0,
                "lat":UserDefaults.standard.lastMyCoordinate?.latitude  ?? 0,
                "textForSearch":text,
                "regTimeIntervalSince1970":now,
                "modifiedTimeIntervalSince1970":now,
                "readDetailCount":0
            ]
            if let game = gameResultBase64encodingString {
                data["gameResultBase64encodingSting"] = game
            }
            if let url = uploadUrl {
                data["imageUrl"] = url.absoluteString
            }
            FS.store.collection(FSCollectionName.TALKS).document(id).setData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.create(TalkModel.self, value: data, update: .all)
                    try! realm.commitWrite()
                    complete(id)
                    NotificationCenter.default.post(name: .talkUpdateNotification, object: nil, userInfo: nil)
                }
                else {
                    complete(nil)
                }
            }
        }
        
        if let url = imageUrl {
            FirebaseStorageHelper().uploadImage(url:url, contentType: "image/jpeg", uploadURL: fileUploadURL) { (url) in
                upload(uploadUrl: url)
            }
        } else {
            upload(uploadUrl: nil)
        }
    }
    
    /** 글 수정하기*/
    func edit(text:String, imageUrl:URL?, complete:@escaping(_ isSucess:Bool)->Void) {
        guard let userId = UserInfo.info?.id else {
            complete(false)
            return
        }
        let editTalkId = id
        let now = Date().timeIntervalSince1970
        let fileUploadURL = "\(FSCollectionName.STORAGE_TLAK_IMAGE)/\(userId)"
        let editId = "\(userId)_\(now)\(UUID().uuidString)"
        
        func edit(uploadUrl:URL?) {
            let data:[String:Any] = [
                "id":editTalkId,
                "textForSearch":text,
                "modifiedTimeIntervalSince1970":now
            ]
            var editData:[String:Any] = [
                "id":editId,
                "text":text,
                "regTimeIntervalSince1970":now,
                "lat":UserDefaults.standard.lastMyCoordinate?.latitude ?? 0,
                "lng":UserDefaults.standard.lastMyCoordinate?.longitude ?? 0
            ]
                        
            if let url = uploadUrl {
                editData["imageUrlStr"] = url.absoluteString
            }
            let doc = FS.store.collection(FSCollectionName.TALKS).document(id)
            doc.updateData(data) { (error1) in
                doc.collection("edit").document(editId).setData(editData) { (error2) in
                    if error1 == nil && error2 == nil {
                        let realm = try! Realm()
                        realm.beginWrite()
                        let talk = realm.create(TalkModel.self, value: data, update: .modified)
                        let edit = realm.create(TextEditModel.self, value: editData, update: .all)
                        talk.editList.append(edit)
                        try! realm.commitWrite()
                        complete(true)
                    } else {
                        complete(false)
                    }
                }
            }
        }
        
        if let url = imageUrl {
            FirebaseStorageHelper().uploadImage(url: url, contentType: "image/jpeg", uploadURL: fileUploadURL) { (url) in
                edit(uploadUrl: url)
            }
        } else {
            edit(uploadUrl: nil)
        }
    }
    
    /** 게시글 동기화*/
    static func syncDatas(complete:@escaping(_ isSucess:Bool)->Void) {
        let realm = try! Realm()
        var syncDt = Date.midnightTodayTime.timeIntervalSince1970
        if let lastTalk = realm.objects(TalkModel.self).sorted(byKeyPath: "modifiedTimeIntervalSince1970").last {
            if syncDt < lastTalk.regTimeIntervalSince1970 {
                syncDt = lastTalk.regTimeIntervalSince1970
            }
        }
        
        let collection = FS.store.collection(FSCollectionName.TALKS)
        collection
            .whereField("modifiedTimeIntervalSince1970", isGreaterThan: syncDt)
            .getDocuments { (shot, error) in
                guard let snap = shot else {
                    return
                }
                if snap.documents.count == 0 {
                    complete(true)
                    return
                }
                let realm = try! Realm()
                realm.beginWrite()
                for doc in snap.documents {
                    let data = doc.data()
                    realm.create(TalkModel.self, value: data, update: .all)
                    /** 문서 아이디*/
                    let id = doc["id"] as! String
                    collection.document(id).collection("edit").getDocuments { (queryShot, error) in
                        if let data = queryShot {
                            let realm = try! Realm()
                            let editList = realm.object(ofType: TalkModel.self, forPrimaryKey: id)?.editList
                            realm.beginWrite()
                            editList?.removeAll()
                            for edits in data.documents {
                                let edit = realm.create(TextEditModel.self, value: edits.data(), update: .all)
                                editList?.append(edit)
                            }
                            try! realm.commitWrite()
                            
                            collection.document(id).collection("like").getDocuments { (likeQueryShot, error) in
                                if let data = likeQueryShot {
                                    let realm = try! Realm()
                                    let likes = realm.object(ofType: TalkModel.self, forPrimaryKey: id)?.likes
                                    realm.beginWrite()
                                    likes?.removeAll()
                                    for info in data.documents {
                                        let like = realm.create(LikeModel.self, value: info.data(), update: .all)
                                        likes?.append(like)
                                    }
                                    try! realm.commitWrite()
                                    complete(true)
                                }
                            }
                        }
                    }
                }
                try! realm.commitWrite()
        }
        
    }
    
    /** 상세 읽기 처리*/
    func readDetail(complete:@escaping(_ sucess:Bool)->Void) {
        guard let userId = UserInfo.info?.id else {
            complete(false)
            return
        }
        let data:[String:Any] = [
            "readTimeIntervalSince1970" : Date().timeIntervalSince1970,
            "creatorId":userId
        ]
        let talkId = self.id
        let document = FS.store.collection(FSCollectionName.TALKS).document(id)
        let reads = document.collection("read")
        let read = reads.document(userId)
        read.setData(data) { (error) in
            if error == nil {
                reads.getDocuments { (queryShot, error) in
                    if let data = queryShot {
                        let count = data.documents.count
                        document.updateData(["readDetailCount" : count])
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.object(ofType: TalkModel.self, forPrimaryKey: talkId)?.readDetailCount = count
                        try! realm.commitWrite()
                        complete(true)
                    }
                    else{
                        complete(false)
                    }
                }
            } else {
                complete(false)
            }
        }
    }
    
    var creator:UserInfo? {
        return try! Realm().object(ofType: UserInfo.self, forPrimaryKey:creatorId)
    }
    
}
