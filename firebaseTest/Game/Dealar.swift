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
        let valuePoint = (cardSet?.cardValue.rawValue ?? 0) + 1
        let random = Int.random(in: 10...20)
        switch Int.random(in:1...10) {
        case 1:
            return 100 + (random * valuePoint * 60)
        case 5:
            return 0
        default:
            return 100 + (random * valuePoint * 20)
        }
    }
}
