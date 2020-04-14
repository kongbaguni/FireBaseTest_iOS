//
//  StoreWaitingModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class StoreWaitingModel : Object {
    enum WaittingStatus : String, CaseIterable {
        case none = "none"
        /** 1명 이상 20명 이하*/
        case p20 = "p20"
        /** 20명 이상 100명 이하*/
        case p100 = "p100"
        /** 100명이상*/
        case manyPeople = "manyPeople"        
    }
    
    @objc dynamic var id:String = "\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    @objc dynamic var status:String = "none"
    var statusValue:WaittingStatus? {
        return WaittingStatus(rawValue: status)
    }
    @objc dynamic var regDtTimeIntervalSince1970:Double = 0
    
    var regDt:Date {
        Date(timeIntervalSince1970: regDtTimeIntervalSince1970)
    }
    
    @objc dynamic var creatorId:String = "" {
        didSet {
            id = "\(UUID().uuidString)_\(creatorId)_\(Date().timeIntervalSince1970)"
        }
    }
    
    @objc dynamic var storeCode:String = ""
    
    var creator:UserInfo? {
        try! Realm().object(ofType: UserInfo.self, forPrimaryKey: creatorId)
    }
    
    var store:StoreModel? {
        try! Realm().object(ofType: StoreModel.self, forPrimaryKey: storeCode)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["storeCode"]
    }
    
    
    static func download(complete:@escaping(_ isSucess:Bool)->Void) {
        
    }
    
    static func uploadLog(storeCode:String, status:String, complete:@escaping(_ sucess:Bool)->Void) {
        let collection = FS.store.collection(FSCollectionName.STORE_STOCK)
        let shopDoc = collection.document(storeCode)
        let subColection = shopDoc.collection("waiting_logs")
        
        guard let uploaderId = UserInfo.info?.id else {
            complete(false)
            return
        }
        let now = Date().timeIntervalSince1970
        
        let id = "\(uploaderId)_\(now)_\(UUID().uuidString)"
        let time = Date().formatedString(format: "yyyyMMdd_HH:mm")
        let document = subColection.document("\(storeCode)_\(time)")

        let data:[String:Any] = [
            "id":id,
            "storeCode":storeCode,
            "status":status,
            "regDtTimeIntervalSince1970":now,
            "creatorId":uploaderId
        ]
        
        shopDoc.setData(["id":storeCode]) { (error) in
            if error == nil {
                document.setData(data, merge: true) { (error) in
                    if error == nil {
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.create(StoreWaitingModel.self, value: data, update: .all)
                        try! realm.commitWrite()
                    }
                    complete(error == nil)
                }
            } else {
                complete(false)
            }
        }
    }

    static func downloadLogs(storeCode code:String, complete:@escaping(_ count:Int?)->Void) {
        let realm = try! Realm()
        var syncDt = Date.getMidnightTime(beforDay: 7).timeIntervalSince1970
        if let lastLog = realm.objects(StoreWaitingModel.self).filter("storeCode = %@",code).sorted(byKeyPath: "regDtTimeIntervalSince1970").last {
            if syncDt < lastLog.regDt.timeIntervalSince1970 {
                syncDt = lastLog.regDt.timeIntervalSince1970
            }
        }
        
        FS.store
            .collection(FSCollectionName.STORE_STOCK)
            .document(code)
            .collection("waiting_logs")
            .whereField("regDtTimeIntervalSince1970", isGreaterThan: syncDt)
            .getDocuments { (shot, error) in
                if error != nil {
                    complete(nil)
                    return
                }
                guard let snap = shot else {
                    complete(nil)
                    return
                }
                let realm = try! Realm()
                
                print("----------------")
                print(code)
                print(snap.documents.count)
                print(snap.documentChanges.count)
                realm.beginWrite()
                for doc in snap.documents {
                    let data = doc.data()
                    realm.create(StoreWaitingModel.self, value: data, update: .all)
                }
                try! realm.commitWrite()
                complete(snap.documents.count)
        }
        
    }

}
