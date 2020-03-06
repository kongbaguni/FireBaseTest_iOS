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

class TalkModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var text:String = ""
    @objc dynamic var creatorId:String = ""
    @objc dynamic var regTimeIntervalSince1970:Double = 0 {
        didSet {
            if modifiedTimeIntervalSince1970 == 0 {
                modifiedTimeIntervalSince1970 = regTimeIntervalSince1970
            }
        }
    }
    @objc dynamic var modifiedTimeIntervalSince1970:Double = 0
    
    func loadData(id:String, text:String, creatorId:String, regTimeIntervalSince1970:Double) {
        self.id = id
        self.text = text
        self.creatorId = creatorId
        self.regTimeIntervalSince1970 = regTimeIntervalSince1970
    }
    
    var regDt:Date {
        return Date(timeIntervalSince1970: regTimeIntervalSince1970)
    }
    
    var regDtStr:String {
        return  DateFormatter.localizedString(from: regDt, dateStyle: .short, timeStyle: .short)
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
    
    /** fireBaseStore 에 생성된 데이터 갱신하기*/
    func update(complete:@escaping(_ isSucess:Bool)->Void) {
        if text.isEmpty {
            return
        }
                
        let data:[String:Any] = [
            "documentId":id,
            "regTimeIntervalSince1970":regTimeIntervalSince1970,
            "modifiedTimeIntervalSince1970":modifiedTimeIntervalSince1970,
            "creator_id":creatorId,
            "talk":text
        ]
        let collection = Firestore.firestore().collection("talks")
        let document = collection.document(id)
        document.setData(data, merge: true) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.add(self, update: .all)
                try! realm.commitWrite()
                complete(true)
                return
            }
            complete(false)
        }
    }
    
    static func syncDatas(complete:@escaping()->Void) {
        let collection = Firestore.firestore().collection("talks")
        collection
            .whereField("regTimeIntervalSince1970", isGreaterThan: Date().timeIntervalSince1970 - Consts.LIMIT_TALK_TIME_INTERVAL)
            .getDocuments { (shot, error) in
                guard let snap = shot else {
                    return
                }
                let realm = try! Realm()
                realm.beginWrite()
                print(snap.documents.count)
                for doc in snap.documents {
                    let data = doc.data()
                    if let regTimeIntervalSince1970 = data["regTimeIntervalSince1970"] as? Double,
                        let modifiedTimeIntervalSince1970 = data["modifiedTimeIntervalSince1970"] as? Double,
                        let creatorId = data["creator_id"] as? String,
                        let text = data["talk"] as? String,
                        let id = data["documentId"] as? String {
                        let model = TalkModel()
                        model.regTimeIntervalSince1970 = regTimeIntervalSince1970
                        model.modifiedTimeIntervalSince1970 = modifiedTimeIntervalSince1970
                        model.creatorId = creatorId
                        model.text = text
                        model.id = id
                        realm.add(model, update: .modified)
                    }
                }
                try! realm.commitWrite()
                complete()
        }
        
    }
    
}
