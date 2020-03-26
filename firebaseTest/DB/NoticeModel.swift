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

class NoticeModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var title:String = ""
    @objc dynamic var text:String = ""
    @objc dynamic var creatorId:String = ""
    @objc dynamic var regDtTimeinterval1970:Double = 0
    @objc dynamic var updateDtTimeinterval1970:Double = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["creatorId"]
    }
    func update(complete:@escaping(_ isSucess:Bool)->Void) {
        let data:[String:Any] = [
            "id"    : id,
            "title" : title,
            "text"  : text,
            "creatorId" : creatorId,
            "regDtTimeinterval1970" : regDtTimeinterval1970,
            "updateDtTimeinterval1970" : updateDtTimeinterval1970
        ]
        let doc = Firestore.firestore().collection(FSCollectionName.NOTICE).document(id)
        doc.setData(data) { (error) in
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
