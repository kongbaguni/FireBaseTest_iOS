//
//  StoreStockLogModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class StoreStockLogModel: Object {
    @objc dynamic var id:String = "\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    @objc dynamic var code:String = ""
    @objc dynamic var remain_stat:String = ""
    @objc dynamic var regDt:Date = Date()
    @objc dynamic var uploaderId:String = ""
    @objc dynamic var uploaded:Bool = false
    
    var uploader:UserInfo? {
        if uploaderId.isEmpty || uploaderId == "guest" {
            return nil
        }
        if let info = try! Realm().object(ofType: UserInfo.self, forPrimaryKey: uploaderId) {
            return info
        }
        return nil
    }
    
    var store:StoreModel? {
        try! Realm().object(ofType: StoreModel.self, forPrimaryKey: code)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["code"]
    }
    
    static func getLastStat(shopcode:String)->String? {
        let realm = try! Realm()
        return realm.objects(StoreStockLogModel.self)
            .filter("code = %@",shopcode)
            .sorted(byKeyPath: "regDt",ascending: true)
            .last?.remain_stat
    }
    
    func uploadStoreStocks(complete:@escaping(_ sucess:Bool)->Void) {
        if self.code == "" {
            complete(false)
            return
        }
        
        let collection = Firestore.firestore().collection(FSCollectionName.STORE_STOCK)
        let docuId = id
        
        let time = self.regDt.formatedString(format: "yyyyMMdd_HHMM") + remain_stat
        let shopDoc = collection.document(code)
        let subColection = shopDoc.collection("stock_logs")
        let document = subColection.document("\(code)_\(time)")
        
        var uploaderId = UserInfo.info?.id ?? "guest"
        if UserInfo.info?.isAnonymousInventoryReport == true {
            uploaderId = "guest"
        }
        let data:[String:Any] = [
            "id":id,
            "shopcode":code,
            "remain_stat":remain_stat,
            "regDtTimeIntervalSince1970":regDt.timeIntervalSince1970,
            "uploader":uploaderId
        ]
        
        shopDoc.setData(["id":code]) { (error) in
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
    
    static func downloadStockLogs(storeCode code:String, complete:@escaping(_ count:Int?)->Void) {
        let realm = try! Realm()
        var syncDt = Date.getMidnightTime(beforDay: 7).timeIntervalSince1970
        if let lastLog = realm.objects(StoreStockLogModel.self).filter("code = %@",code).sorted(byKeyPath: "regDt").last {
            if syncDt < lastLog.regDt.timeIntervalSince1970 {
                syncDt = lastLog.regDt.timeIntervalSince1970
            }
        }
        
        Firestore.firestore()
            .collection(FSCollectionName.STORE_STOCK)
            .document(code)
            .collection("stock_logs")
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
                        , let remain_stat = data["remain_stat"] as? String
                        , let storeCode = data["shopcode"] as? String
                    {
                        let lastLog = realm.objects(StoreStockLogModel.self).filter("code = %@", storeCode).sorted(byKeyPath: "regDt").last
                        #if DEBUG
                        if lastLog?.isInvalidated == false {
                            print("last : \(lastLog?.regDt.simpleFormatStringValue ?? " ") : \(lastLog?.remain_stat ?? " ") \(lastLog?.code ?? " ")")
                        }
                        print(Date(timeIntervalSince1970: doc["regDtTimeIntervalSince1970"] as! Double).simpleFormatStringValue
                            + " " + remain_stat + " " + storeCode)
                        #endif
                        
                        if lastLog?.remain_stat != remain_stat || lastLog?.isInvalidated == true {
                            
                            let logModel = StoreStockLogModel()
                            logModel.id = id
                            logModel.code =  storeCode
                            logModel.remain_stat = remain_stat
                            logModel.uploaderId = data["uploader"] as? String ?? "guest"
                            logModel.uploaded = true
                            
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
