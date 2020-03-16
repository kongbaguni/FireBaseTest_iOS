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
        func upload() {
            if self.code == "" {
                complete(false)
                return
            }
            let collection = Firestore.firestore().collection("storeStock")
            let docuId = id

            let time = self.regDt.formatedString(format: "yyyyMMdd_HHMM") + remain_stat
            let shopDoc = collection.document(code)
            let subColection = shopDoc.collection("stock_logs")
            let document = subColection.document("\(code)_\(time)")
            
            let data:[String:Any] = [
                "id":id,
                "shopcode":code,
                "remain_stat":remain_stat,
                "regDtTimeIntervalSince1970":regDt.timeIntervalSince1970,
                "uploader":UserInfo.info?.id ?? "guest"
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

        upload()
    }
}
