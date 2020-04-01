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
    static let game_popCardFromCardDeckBox = Notification.Name("game_popCardFromCardDeckBoxObserver")
}


/** 포인트 사용. 경험치 축적. 게임 관리 등을 위한 클래스*/
class GameManager {
    static let shared = GameManager()
    let info = UserInfo.info!
    /** 포인트 사용하기*/
    func usePoint(point:Int,complete:@escaping(_ sucess:Bool)->Void) {
        info.addPoint(point: -point) { (sucess) in
            if sucess {
                self.info.update(data: ["exp": self.info.exp + point]) { (sucess) in
                    complete(sucess)
                }
            } else {
                complete(false)
            }
        }
    }
    
    /** 포인트 더하기*/
    func addPoint(point:Int,complete:@escaping(_ sucess:Bool)->Void) {
        info.addPoint(point: point, complete: complete)
    }
    let googleAd = GoogleAd()
    
    var deckBoxCardsCount:Int {
        return cardDack.count
    }
    
    fileprivate var cardDack:[Card] = [] {
        didSet {
            NotificationCenter.default.post(name: .game_popCardFromCardDeckBox, object: deckBoxCardsCount)
        }
    }
    fileprivate var isUseJoker = false
    
    var shuffleLimit = 5
    
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
    
    func popCards(number:Int)->[Card] {
        var list:[Card] = []
        if number == 0 {
            return []
        }
        while list.count < number {
            if cardDack.count < shuffleLimit {
                insertCardAndShuffle(useJoker: self.isUseJoker)
            }
            if let card = cardDack.first {
                list.append(card)
                cardDack.removeFirst()
            }
        }
        return list
    }
    
    var pop5Cards:CardSet {
        CardSet(cards: popCards(number: 5))
    }
        
    func showAd(popoverView:Any,adcomplete:@escaping()->Void) {
        let msg = String(format:"Not enough points.\nCurrent Point: %@".localized, UserInfo.info?.point.decimalForamtString ?? "0")
        let vc = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Receive points".localized, style: .default, handler: { (_) in
            self.googleAd.showAd(targetViewController: UIApplication.shared.lastViewController!) { (isSucess) in
                if isSucess {
                    GameManager.shared.addPoint(point: AdminOptions.shared.adRewardPoint) { (isSucess) in
                        if isSucess {
                            let msg = String(format:"%@ point get!".localized, AdminOptions.shared.adRewardPoint.decimalForamtString)
                            Toast.makeToast(message: msg)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                adcomplete()
                            }
                        }
                    }
                }
            }
        }))
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        if let view = popoverView as? UIView {
            vc.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: view)
        }
        if let item = popoverView as? UIBarButtonItem {
            vc.popoverPresentationController?.barButtonItem = item
        }
        UIApplication.shared.lastViewController!.present(vc, animated: true, completion: nil)
    }
}
