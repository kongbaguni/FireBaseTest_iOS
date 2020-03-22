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
    @objc dynamic var regDt:Date = Date()
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
    
    func uploadLog(complete:@escaping(_ sucess:Bool)->Void) {
        if self.storeCode == "" {
            complete(false)
            return
        }
        let collection = Firestore.firestore().collection(FSCollectionName.STORE_STOCK)
        
        let docuId = id
        
        let time = self.regDt.formatedString(format: "yyyyMMdd_HHMMss") + status
        let shopDoc = collection.document(storeCode)
        let subColection = shopDoc.collection("waiting_logs")
        let document = subColection.document("\(storeCode)_\(time)")
        
        guard let uploaderId = UserInfo.info?.id else {
            complete(false)
            return
        }
        
        let data:[String:Any] = [
            "id":id,
            "storeCode":storeCode,
            "status":status,
            "regDtTimeIntervalSince1970":regDt.timeIntervalSince1970,
            "uploader":uploaderId
        ]
        
        shopDoc.setData(["id":storeCode]) { (error) in
            if error == nil {
                document.setData(data, merge: true) { (error) in
                    if error == nil {
                        let realm = try! Realm()
                        if let data = realm.object(ofType: StoreStockLogModel.self, forPrimaryKey: docuId) {
                            realm.beginWrite()
                            data.uploaded = true
                            try! realm.commitWrite()
                        }
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
        if let lastLog = realm.objects(StoreWaitingModel.self).filter("storeCode = %@",code).sorted(byKeyPath: "regDt").last {
            if syncDt < lastLog.regDt.timeIntervalSince1970 {
                syncDt = lastLog.regDt.timeIntervalSince1970
            }
        }
        
        Firestore.firestore()
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
                for doc in snap.documents {
                    let data = doc.data()
                    if let id = data["id"] as? String
                        , let status = data["status"] as? String
                        , let storeCode = data["storeCode"] as? String
                    {
                        let lastLog = realm.objects(StoreWaitingModel.self).filter("storeCode = %@", storeCode).sorted(byKeyPath: "regDt").last
                        
                        if lastLog?.status != status || lastLog?.isInvalidated == true {
                            
                            let logModel = StoreWaitingModel()
                            logModel.id = id
                            logModel.storeCode =  storeCode
                            logModel.status = status
                            logModel.creatorId = data["uploader"] as? String ?? "guest"
                            
                            if let int = data["regDtTimeIntervalSince1970"] as? Double {
                                logModel.regDt = Date(timeIntervalSince1970: int)
                            }
                            realm.beginWrite()
                            realm.add(logModel, update: .all)
                            try! realm.commitWrite()
                        }
                    }
                }
                complete(snap.documents.count)
        }
        
    }

}
