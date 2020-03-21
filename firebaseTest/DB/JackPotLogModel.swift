//
//  JackPotLogModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
class JackPotLogModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var point:Int = 0
    @objc dynamic var regTimeIntervalSince1970:Double = 0
    @objc dynamic var userId:String = ""
    
    override static func primaryKey() -> String? {
          return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["userId"]
    }
      
    
    var user:UserInfo? {
        return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: userId)
    }
    
    var regDt:Date {
        return Date(timeIntervalSince1970: regTimeIntervalSince1970)
    }
}
