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
    @objc dynamic var id:String = "" {
        didSet {
            let list = id.components(separatedBy: "[__##__]")
            if let str = list.last {
                let int = TimeInterval(NSString(string: str).doubleValue)
                regDt = Date(timeIntervalSince1970: int)
            }
            if let id = list.first {
                creatorId = id
            }
        }
    }
    @objc dynamic private var creatorId:String = ""
    
    func set(creatorId:String, targetTalkId:String) {
        self.creatorId = creatorId
        id = "\(creatorId)[__##__]\(targetTalkId)[__##__]\(UUID().uuidString)[__##__]\(Date().timeIntervalSince1970)"
    }
        
    var creator:UserInfo? {
        return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: creatorId)
    }
    
    var targetTalkId:String {
        id.components(separatedBy: "[__##__]")[1]
    }

    var targetTalk:TalkModel? {
        return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: targetTalkId)
    }

    @objc dynamic var regDt:Date = Date()
    

    override static func primaryKey() -> String? {
        return "id"
    }
        
    override static func indexedProperties() -> [String] {
        return ["creatorId"]
    }
}
