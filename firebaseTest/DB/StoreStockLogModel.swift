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
    
    @objc dynamic var uploaded:Bool = false
    
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
            let docuId = code

            let time = self.regDt.formatedString(format: "yyyyMMdd_HH") + remain_stat
            let document = collection.document("\(code)_\(time)")
            let data:[String:Any] = [
                "id":id,
                "shopcode":code,
                "remain_stat":remain_stat,
                "regDtTimeIntervalSince1970":regDt.timeIntervalSince1970
            ]
            
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
        }

        upload()
    }
}
