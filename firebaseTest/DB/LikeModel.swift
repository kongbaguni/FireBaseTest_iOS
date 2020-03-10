//
//  LikeModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/09.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
class LikeModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var creatorId:String = "" {
        didSet {
            regDt = Date()
            id = "\(UUID().uuidString),\(creatorId),\(regDt.timeIntervalSince1970)"
        }
    }
    
    @objc dynamic var targetTalkId:String = ""
    @objc dynamic var regDt:Date = Date()
    
    func set(creatorId:String, targetTalkId:String) {
        self.creatorId = creatorId
        self.targetTalkId = targetTalkId
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
        
    
}
