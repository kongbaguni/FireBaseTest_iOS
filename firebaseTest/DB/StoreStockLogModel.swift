//
//  StoreStockLogModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift

class StoreStockLogModel: Object {
    @objc dynamic var id:String = "\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    @objc dynamic var code:String = ""
    @objc dynamic var remain_stat:String = ""
    @objc dynamic var regDt:Date = Date()
    
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
}
