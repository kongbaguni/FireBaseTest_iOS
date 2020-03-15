//
//  GameManager.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift

extension Notification.Name {
    static let game_levelupNotification = Notification.Name("levelupNotificationObserver")
    static let game_usePointAndGetExpNotification = Notification.Name("usePointAndGetExpNotificationObserver")
    static let game_getPointNotification = Notification.Name("game_getPointNotificationObserver")
}


/** 포인트 사용. 경험치 축적. 게임 관리 등을 위한 클래스*/
class GameManager {
    static let shared = GameManager()
    let info = UserInfo.info!
    /** 포인트 사용하기*/
    func usePoint(point:Int,complete:@escaping(_ sucess:Bool)->Void) {
        info.addPoint(point: -point) { (sucess) in
//            if sucess {
//                let change = StatusChange(addedExp: point, pointChange: -point)
//                NotificationCenter.default.post(name: .game_usePointAndGetExpNotification, object: change, userInfo: nil)
//            }
            complete(sucess)
        }
    }
    
    /** 포인트 더하기*/
    func addPoint(point:Int,complete:@escaping(_ sucess:Bool)->Void) {
        info.addPoint(point: point, complete: complete)
    }
    let googleAd = GoogleAd()
    
    fileprivate var cardDack:[Card] = []
    fileprivate var isUseJoker = false
    
    fileprivate func insertCardAndShuffle(useJoker:Bool) {
        var list:[Card] = []
        if self.isUseJoker != useJoker {
            cardDack.removeAll()
        }
        isUseJoker = useJoker
        if useJoker {
            for card in Card.jokerCards {
                list.append(card)
            }
        }
        for card in Card.cards {
            list.append(card)
        }
        list.shuffle()
        for card in list {
            cardDack.append(card)
        }
    }
    
    fileprivate var popCards:CardSet {
        var list:[Card] = []
        
        while list.count < 5 {
            if cardDack.count == 0 {
                insertCardAndShuffle(useJoker: self.isUseJoker)
            }
            if let card = cardDack.first {
                list.append(card)
                cardDack.removeFirst()
            }
        }
        return CardSet(cards: list)
    }
    
    func playPokerGame(useJoker:Bool,bettingPoint:Int,complete:@escaping(_ isSucess:Bool)->Void) {      
        func playGame() {
            if self.cardDack.isEmpty {
                insertCardAndShuffle(useJoker: useJoker)
            }
            
            let cards = GameManager.shared.popCards
            let d_cards = GameManager.shared.popCards
            
            let talkModel = TalkModel()
            let documentId = "card\(UUID().uuidString)\(UserInfo.info!.id)\(Date().timeIntervalSince1970)"
            let creatorId = UserInfo.info!.id
            let regTimeIntervalSince1970 = Date().timeIntervalSince1970
            talkModel.loadData(id: documentId, text: "", creatorId: creatorId, regTimeIntervalSince1970: regTimeIntervalSince1970)
            talkModel.cardSet = cards
            talkModel.delarCardSet = d_cards
            talkModel.bettingPoint = bettingPoint
            var gameResult:CardSet.GameResult = .tie
            
            if let card1 = talkModel.cardSet, let card2 = talkModel.delarCardSet {
                gameResult = card1.getGameResult(targetCardSet: card2)
            }
            
            var pointGetStr = ""
            var resultPoint = talkModel.creator?.point ?? 0
            switch gameResult {
            case .win:
                pointGetStr = "+" + (bettingPoint).decimalForamtString
                resultPoint += (bettingPoint * 2)
            case .lose:
                pointGetStr = "-" + (bettingPoint).decimalForamtString
            case .tie:
                pointGetStr = "+0"
                resultPoint += bettingPoint
            }
            
            let format = "%@ point betting %@ %@\n%@ point %@ point".localized
            let msg = String(
                format: format
                , bettingPoint.decimalForamtString
                , cards.cardValue.stringValue.localized
                , gameResult.rawValue.localized
                , pointGetStr
                , resultPoint.decimalForamtString
            )
            talkModel.text = msg
            
            talkModel.update {(isSucess) in
                switch gameResult {
                case .win:
                    self.addPoint(point: bettingPoint * 2) { (sucess) in
                        NotificationCenter.default.post(name: .game_usePointAndGetExpNotification, object: StatusChange(addedExp: bettingPoint, pointChange: bettingPoint), userInfo: nil)

                        complete(sucess)
                    }
                case .tie:
                    self.addPoint(point: bettingPoint) { (sucess) in
                        NotificationCenter.default.post(name: .game_usePointAndGetExpNotification, object: StatusChange(addedExp: bettingPoint, pointChange: 0), userInfo: nil)
                        complete(sucess)
                    }
                default :
                    NotificationCenter.default.post(name: .game_usePointAndGetExpNotification, object: StatusChange(addedExp: bettingPoint, pointChange: -bettingPoint), userInfo: nil)
                    complete(isSucess)
                    break
                }
            }
        }

        usePoint(point: bettingPoint) { (sucess) in
            if sucess {
                playGame()
            }
        }
        
    }
}
