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
    @objc dynamic var creatorId:String = ""
    @objc dynamic var targetTalkId:String = ""
    @objc dynamic var regTimeIntervalSince1970:Double = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
        
    override static func indexedProperties() -> [String] {
        return ["creatorId"]
    }
}

extension LikeModel {
    var creator:UserInfo? {
        return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: creatorId)
    }
    
    var targetTalk:TalkModel? {
        return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: targetTalkId)
    }
}
