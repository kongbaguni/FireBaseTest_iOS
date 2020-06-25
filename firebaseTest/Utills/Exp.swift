//
//  Exp.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/24.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
class Exp {
    fileprivate let exp:Int
    init(_ exp:Int) {
        self.exp = exp
    }
    
    var level:Int {
        var e = self.exp
        var level = 0
        while e >= 0 {
            e -= (AdminOptions.shared.levelupReqExpBase + level * AdminOptions.shared.levelupReqExpPlus)
            level += 1
        }
        return level
    }
    
    /** 이전 레벨까지 경험치*/
    var prevLevelExp:Int {
        var exp = 0
        for i in 0..<level-1 {
            exp += AdminOptions.shared.levelupReqExpBase + (AdminOptions.shared.levelupReqExpPlus * i)
        }
        return exp
    }
    
    /** 다음 레벨까지 경험치*/
    var nextLevelupExp:Int {
        var exp = 0
        for i in 0..<level {
            exp += AdminOptions.shared.levelupReqExpBase + (AdminOptions.shared.levelupReqExpPlus * i)
        }
        return exp
    }
}
