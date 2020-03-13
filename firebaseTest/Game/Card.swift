//
//  Card.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit

struct Card {
    /** 카드타입*/
    enum CardType:String {
        case spade = "S"
        case heart = "H"
        case diamond = "D"
        case club = "C"
        case joker = "J"
    }
    
    let type:CardType
    let index:Int
    
    /** 카드가 가지는 값*/
    var value:Int {
        if type == .joker {
            return 10
        }
        switch index {
        case 1,11,12,13:
            return 10
        default:
            return index
        }
    }
    
    var typeValue:String {
        return type.rawValue
    }
    
    /** 카드를 문자열로 표현*/
    var stringValue:String {
        var result = type.rawValue
        switch index {
        case 1:
            result += "A"
        case 11:
            result += "J"
        case 12:
            result += "Q"
        case 13:
            result += "K"
        default:
            result += "\(index)"
        }
        return result
    }
    
    var image:UIImage? {
        switch type {
        case .joker:
            return #imageLiteral(resourceName: "joker")
        case .club:
            switch index {
            case 1: return #imageLiteral(resourceName: "AC")
            case 2: return #imageLiteral(resourceName: "2C")
            case 3: return #imageLiteral(resourceName: "3C")
            case 4: return #imageLiteral(resourceName: "4C")
            case 5: return #imageLiteral(resourceName: "5C")
            case 6: return #imageLiteral(resourceName: "6C")
            case 7: return #imageLiteral(resourceName: "7C")
            case 8: return #imageLiteral(resourceName: "8C")
            case 9: return #imageLiteral(resourceName: "9C")
            case 10: return #imageLiteral(resourceName: "10C")
            case 11: return #imageLiteral(resourceName: "JC")
            case 12: return #imageLiteral(resourceName: "QC")
            case 13: return #imageLiteral(resourceName: "KC")
            default:return nil
            }
        case .heart:
            switch index {
            case 1: return #imageLiteral(resourceName: "AH")
            case 2: return #imageLiteral(resourceName: "2H")
            case 3: return #imageLiteral(resourceName: "3H")
            case 4: return #imageLiteral(resourceName: "4H")
            case 5: return #imageLiteral(resourceName: "5H")
            case 6: return #imageLiteral(resourceName: "6H")
            case 7: return #imageLiteral(resourceName: "7H")
            case 8: return #imageLiteral(resourceName: "8H")
            case 9: return #imageLiteral(resourceName: "9H")
            case 10: return #imageLiteral(resourceName: "10H")
            case 11: return #imageLiteral(resourceName: "JH")
            case 12: return #imageLiteral(resourceName: "QH")
            case 13: return #imageLiteral(resourceName: "KH")
            default: return nil
            }
        case .diamond:
            switch index {
            case 1: return #imageLiteral(resourceName: "AD")
            case 2: return #imageLiteral(resourceName: "2D")
            case 3: return #imageLiteral(resourceName: "3D")
            case 4: return #imageLiteral(resourceName: "4D")
            case 5: return #imageLiteral(resourceName: "5D")
            case 6: return #imageLiteral(resourceName: "6D")
            case 7: return #imageLiteral(resourceName: "7D")
            case 8: return #imageLiteral(resourceName: "8D")
            case 9: return #imageLiteral(resourceName: "9D")
            case 10: return #imageLiteral(resourceName: "10D")
            case 11: return #imageLiteral(resourceName: "JD")
            case 12: return #imageLiteral(resourceName: "QD")
            case 13: return #imageLiteral(resourceName: "KD")
            default: return nil
            }
        case .spade:
            switch index {
            case 1: return #imageLiteral(resourceName: "AS")
            case 2: return #imageLiteral(resourceName: "2S")
            case 3: return #imageLiteral(resourceName: "3S")
            case 4: return #imageLiteral(resourceName: "4S")
            case 5: return #imageLiteral(resourceName: "5S")
            case 6: return #imageLiteral(resourceName: "6S")
            case 7: return #imageLiteral(resourceName: "7S")
            case 8: return #imageLiteral(resourceName: "8S")
            case 9: return #imageLiteral(resourceName: "9S")
            case 10: return #imageLiteral(resourceName: "10S")
            case 11: return #imageLiteral(resourceName: "JS")
            case 12: return #imageLiteral(resourceName: "QS")
            case 13: return #imageLiteral(resourceName: "KS")
            default: return nil
            }
        }
    }
    
    /** 조커 카드 세트*/
    static let jokerCards:[Card] = [
        Card(type: .joker, index: 0),
        Card(type: .joker, index: 0),
        Card(type: .joker, index: 0),
        Card(type: .joker, index: 0),
    ]

    /** 일반 카드세트*/
    static let cards:[Card] = [
        Card(type: .club, index: 1),
        Card(type: .club, index: 2),
        Card(type: .club, index: 3),
        Card(type: .club, index: 4),
        Card(type: .club, index: 5),
        Card(type: .club, index: 6),
        Card(type: .club, index: 7),
        Card(type: .club, index: 8),
        Card(type: .club, index: 9),
        Card(type: .club, index: 10),
        Card(type: .club, index: 11),
        Card(type: .club, index: 12),
        Card(type: .club, index: 13),
        Card(type: .heart, index: 1),
        Card(type: .heart, index: 2),
        Card(type: .heart, index: 3),
        Card(type: .heart, index: 4),
        Card(type: .heart, index: 5),
        Card(type: .heart, index: 6),
        Card(type: .heart, index: 7),
        Card(type: .heart, index: 8),
        Card(type: .heart, index: 9),
        Card(type: .heart, index: 10),
        Card(type: .heart, index: 11),
        Card(type: .heart, index: 12),
        Card(type: .heart, index: 13),
        Card(type: .diamond, index: 1),
        Card(type: .diamond, index: 2),
        Card(type: .diamond, index: 3),
        Card(type: .diamond, index: 4),
        Card(type: .diamond, index: 5),
        Card(type: .diamond, index: 6),
        Card(type: .diamond, index: 7),
        Card(type: .diamond, index: 8),
        Card(type: .diamond, index: 9),
        Card(type: .diamond, index: 10),
        Card(type: .diamond, index: 11),
        Card(type: .diamond, index: 12),
        Card(type: .diamond, index: 13),
        Card(type: .spade, index: 1),
        Card(type: .spade, index: 2),
        Card(type: .spade, index: 3),
        Card(type: .spade, index: 4),
        Card(type: .spade, index: 5),
        Card(type: .spade, index: 6),
        Card(type: .spade, index: 7),
        Card(type: .spade, index: 8),
        Card(type: .spade, index: 9),
        Card(type: .spade, index: 10),
        Card(type: .spade, index: 11),
        Card(type: .spade, index: 12),
        Card(type: .spade, index: 13)
    ]
    
    static func makeCardWithString(string:String)->Card? {
        if string.isEmpty {
            return nil
        }
        let first = String(string.first!)
        guard let second = string.components(separatedBy: first).last else {
            return nil
        }
        guard let type = Card.CardType(rawValue: first) else {
            return nil
        }
        var code = 0
        
        switch second.uppercased() {
        case "A":
            code = 1
        case "J":
            code = 11
        case "Q":
            code = 12
        case "K":
            code = 13
        default:
            code = NSString(string: second).integerValue
        }
        return Card(type: type, index: code)
    }
    
}


struct CardSet {
    enum GameResult : String {
        case win = "win"
        case lose = "lose"
        case tie = "tie"
    }
    
    /** 카드 족보*/
    enum CardValue:Int {
        case highcard = 0
        case onePair = 1
        case twoPairs = 2
        case threeOfaKind = 3
        case straight = 4
        case flush = 5
        case fullHouse = 6
        case fourOfaKind = 7
        case straightFlush = 8
        case fiveOfaKind = 9
        var stringValue:String {
            switch self {
            case .highcard:
                return "highcard".localized
            case .onePair:
                return "onePair".localized
            case .twoPairs:
                return "twoPairs".localized
            case .threeOfaKind:
                return "threeOfaKind".localized
            case .straight:
                return "straight".localized
            case .flush:
                return "flush".localized
            case .fullHouse:
                return "fullHouse".localized
            case .fourOfaKind:
                return "fourOfaKind".localized
            case .straightFlush:
                return "straightFlush".localized
            case .fiveOfaKind:
                return "fiveOfaKind".localized
            }
        }
    }
    
    let cards:[Card]
    
    /** 뽑은 카드의 문자열*/
    var stringValue:String {
        var result:String = ""
        for card in cards {
            if !result.isEmpty {
                result += ","
            }
            result += card.stringValue
        }
        return result
    }
    
    var cardValue:CardValue {
        if cards.count == 5 {
            let a = cards.sorted { (a, b) -> Bool in
                return a.index > b.index
            }
            
            var check:[Int] = []
            var checks:[Int:Int] = [:]
            for i in 0...13 {
                checks[i] = 0
            }
            
            var types = Set<String>()
            var indexes = Set<Int>()
            
            for c in a {
                check.append(c.index)
                checks[c.index]! += 1
                types.insert(c.type.rawValue)
                indexes.insert(c.index)
            }
            
            /** 4장이 같다 */
            var is4one = 0
            /** 3장이 같다 */
            var is3one = 0
            /** 2장이 같다**/
            var is2one = 0
            for item in checks {
                if item.value == 4 {
                    is4one += 1
                }
                if item.value == 3 {
                    is3one += 1
                }
                if item.value == 2 {
                    is2one += 1
                }
            }
            
            if is4one == 1 && checks[0] == 1 {
                return .fiveOfaKind
            }
            
            var isStraight = false
            if (check[0] - check[1] == 1)
                && (check[1] - check[2] == 1)
                && (check[2] - check[3] == 1)
                && (check[3] - check[4] == 1) {
                isStraight = true
            }
            
            let isFlush = types.count == 1
            
            if isStraight && isFlush {
                return .straightFlush
            }
            
            
            if is4one == 1 {
                return .fourOfaKind
            }
            if is3one == 1 && is2one == 1 {
                return .fullHouse
            }
            if isFlush {
                return .flush
            }
            if isStraight {
                return .straight
            }
            if is3one == 1{
                return .threeOfaKind
            }
            if is2one == 2 {
                return .twoPairs
            }
            if is2one == 1 {
                return .onePair
            }
            
        }
        return .highcard
    }
    
    static func makeCardsWithString(string:String)->CardSet? {
        let list = string.components(separatedBy: ",")
        var cards:[Card] = []
        for txt in list {
            if let card = Card.makeCardWithString(string: txt) {
                cards.append(card)
            }
        }
        if cards.count == 0 {
            return nil
        }
        return CardSet(cards: cards)
    }
    
    var point:Int {
        var point = 0
        for card in cards {
            point += card.value
        }
        return point
    }
    
    func getGameResult(targetCardSet:CardSet)->GameResult {
        if point > targetCardSet.point {
            return .win
        } else if point < targetCardSet.point {
            return .lose
        }
        return .tie
    }
}
