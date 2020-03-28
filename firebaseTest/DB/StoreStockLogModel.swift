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
    @objc dynamic var regDtTimeIntervalSince1970 : Double = 0    
    @objc dynamic var uploaderId:String = ""
    
    var regDt:Date {
        Date(timeIntervalSince1970: regDtTimeIntervalSince1970)
    }
    
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
            .sorted(byKeyPath: "regDtTimeIntervalSince1970",ascending: true)
            .last?.remain_stat
    }
    
    static func uploadStoreStocks(code:String, remain_stat:String, complete:@escaping(_ sucess:Bool)->Void) {
        guard let uploaderId = UserInfo.info?.id else {
            complete(false)
            return
        }
        let collection = Firestore.firestore().collection(FSCollectionName.STORE_STOCK)
        let shopDoc = collection.document(code)
        
        let now = Date().timeIntervalSince1970
        let data:[String:Any] = [
            "id":"\(uploaderId)_\(UUID().uuidString)_\(Date().timeIntervalSince1970)",
            "code":code,
            "remain_stat":remain_stat,
            "regDtTimeIntervalSince1970":now,
            "uploaderId":uploaderId
        ]
                
        shopDoc.setData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(StoreStockLogModel.self, value: data, update: .modified)
                try! realm.commitWrite()
                complete(true)
            }
            else {
                complete(false)
            }
        }
    }
    
    static func downloadStockLogs(storeCode code:String, complete:@escaping(_ count:Int?)->Void) {
        let realm = try! Realm()
        var syncDt = Date.getMidnightTime(beforDay: 7).timeIntervalSince1970
        if let lastLog = realm.objects(StoreStockLogModel.self).filter("code = %@",code).sorted(byKeyPath: "regDtTimeIntervalSince1970").last {
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
                realm.beginWrite()
                for doc in snap.documents {
                    let data = doc.data()
                    realm.create(StoreStockLogModel.self, value: data, update: .all)
                }
                try! realm.commitWrite()
                
                complete(snap.documents.count)
        }
        
    }
}
