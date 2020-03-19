//
//  Dealar.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/17.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
// 카드 족보에 따라 딜러가 베팅하는 금액을 구합니다.
class Dealar {
    var cardSet:CardSet? = nil
    
    var bettingPoint:Int {
        let max = AdminOptions.shared.maxBettingPoint
        
        let valuePoint = (cardSet?.cardValue.rawValue ?? 0) + 1

        let random1 = Float.random(in: 0...1)
        let random2 = Float.random(in: 0...1)
        if Int.random(in: 0...1) == 0 {
            if random2 <= AdminOptions.shared.dealarMaxBettingRate {
                return max
            }
            if random1 <= AdminOptions.shared.dealarZeroPointBettingRate  {
                return 0
            }
        }
        else {
            if random1 <= AdminOptions.shared.dealarZeroPointBettingRate {
                return 0
            }
            if random2 <= AdminOptions.shared.dealarMaxBettingRate {
                return max
            }
        }
        
        let value = 100 + (Int.random(in: 0...1000) * valuePoint * 60)
        if value > max {
            return max
        }
        return value
    }
}
