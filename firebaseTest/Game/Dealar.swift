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
        
        let value = Int((Float.random(in: 0...Float(max)) / 2) * Float(valuePoint))
        if value > max {
            return max
        }
        if value > 10000 {
            return (value / 5000) * 5000
        }
        if value > 5000 {
            return (value / 1000) * 1000
        }
        if value > 1000 {
            return (value / 500) * 500
        }
        if value > 500 {
            return (value / 100) * 100
        }
        if value > 100 {
            return (value / 50) * 50
        }
        if value > 50 {
            return (value / 10) * 10
        }
        if value > 10 {
            return (value / 5) * 5
        }
        return value
    }
}
