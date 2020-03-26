//
//  NoticeModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/26.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore
extension Notification.Name {
    static let noticeUpdateNotification = Notification.Name("noticeUpdateNotification_observer")
}

class NoticeModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var title:String = ""
    @objc dynamic var text:String = ""
    @objc dynamic var creatorId:String = ""
    @objc dynamic var regDtTimeinterval1970:Double = 0
    @objc dynamic var updateDtTimeinterval1970:Double = 0
    /** 관리자가 설정함. */
    @objc dynamic var isShow:Bool = false
    /** 사용자가 봤는지 설정.*/
    @objc dynamic var isRead:Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["creatorId"]
    }
    
    
    func read() {
        let realm = try! Realm()
        realm.beginWrite()
        self.isRead = true
        try! realm.commitWrite()
        NotificationCenter.default.post(name: .noticeUpdateNotification, object: nil, userInfo: nil)
    }
    
    static func create(title:String,text:String,isShow:Bool,complete:@escaping(_ isSucess:Bool)->Void) {
        let now = Date().timeIntervalSince1970
        let id = "\(UUID().uuidString)_\(now)_\(UserInfo.info!.id)"
        let data:[String:Any] = [
            "id"    : id,
            "title" : title,
            "text"  : text,
            "creatorId" : UserInfo.info!.id,
            "regDtTimeinterval1970" : now,
            "updateDtTimeinterval1970" : now,
            "isShow" : isShow,
            "isRead" : false
        ]
        let doc = Firestore.firestore().collection(FSCollectionName.NOTICE).document(id)
        doc.setData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(NoticeModel.self, value: data, update: .all)
                try! realm.commitWrite()
            }
            complete(error == nil)
        }
    }
    
    func edit(title:String, text:String, isShow:Bool,complete:@escaping(_ isSucess:Bool)->Void) {
        let doc = Firestore.firestore().collection(FSCollectionName.NOTICE).document(id)
        let now = Date().timeIntervalSince1970
        let data:[String:Any] = [
            "title" : title,
            "text" : text,
            "updateDtTimeinterval1970" : now,
            "isShow" : isShow
        ]
        let id = self.id
        doc.updateData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                if let model = realm.object(ofType: NoticeModel.self, forPrimaryKey: id) {
                    realm.beginWrite()
                    model.title = title
                    model.text = text
                    model.updateDtTimeinterval1970 = now
                    model.isShow = isShow
                    try! realm.commitWrite()
                    NotificationCenter.default.post(name: .noticeUpdateNotification, object: self.id)
                }
            }
            complete(error == nil)
        }
    }

    /** firebase 에서 공지 삭제*/
    func delete(complete:@escaping(_ isSucess:Bool)->Void) {
        let doc = Firestore.firestore().collection(FSCollectionName.NOTICE).document(id)
        doc.delete { (error) in
            if error == nil {
                NotificationCenter.default.post(name: .noticeUpdateNotification, object: self.id)
            }
            complete(error == nil)
        }
    }
    
    static func syncNotices(complete:@escaping(_ isSucess:Bool)->Void) {
        let collection = Firestore.firestore().collection(FSCollectionName.NOTICE)
        var query = collection.whereField("updateDtTimeinterval1970", isGreaterThanOrEqualTo: 0)
        if let lastNotice = try! Realm().objects(NoticeModel.self).sorted(byKeyPath: "updateDtTimeinterval1970").last {
            query = collection.whereField("updateDtTimeinterval1970", isGreaterThan: lastNotice.updateDtTimeinterval1970)
        }
        query.getDocuments { (snapShot, err) in
            if let data = snapShot {
                let realm = try! Realm()
                realm.beginWrite()
                for document in data.documents {
                    realm.create(NoticeModel.self, value: document.data(), update: .all)
                }
                try! realm.commitWrite()
                complete(true)
                return
            }
            complete(false)
        }
    }
}
