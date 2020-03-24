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
        var level = 1
        while e > 0 {
            e -= (AdminOptions.shared.levelup_req_exp_base + level * AdminOptions.shared.levelup_req_exp_plus)
            level += 1
        }
        return level
    }
    
    /** 이전 레벨까지 경험치*/
    var prevLevelExp:Int {
        var exp = 0
        for i in 0..<level-1 {
            exp += AdminOptions.shared.levelup_req_exp_base + (AdminOptions.shared.levelup_req_exp_plus * i)
        }
        return exp
    }
    
    /** 다음 레벨까지 경험치*/
    var nextLevelupExp:Int {
        var exp = 0
        for i in 0...level-1 {
            exp += AdminOptions.shared.levelup_req_exp_base + (AdminOptions.shared.levelup_req_exp_plus * i)
        }
        return exp
    }
}
