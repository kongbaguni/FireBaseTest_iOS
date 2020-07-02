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
    struct BonusPoint {
        let point:Int
        let bonusMultiple:Int
        var finalPoint:Int {
            return point * bonusMultiple
        }
    }
    
    static let shared = GameManager()
    var info:UserInfo {
        return UserInfo.info!
    }
    /** 포인트 사용하기*/
    func usePoint(point:Int, exp:Int? = nil, complete:@escaping(_ sucess:Bool)->Void) {
        let newExp = self.info.exp + (exp ?? point)
        info.addPoint(point: -point) { (sucess) in
            if sucess {
                self.info.update(data: ["exp": newExp]) { (sucess) in
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
            if let alert = UIApplication.shared.lastViewController as? UIAlertController {
                alert.dismiss(animated: false, completion: nil)
            }
            self.googleAd.showAd(targetViewController: UIApplication.shared.lastViewController!) { (isSucess) in
                if isSucess {
                    let bonusPoint = GameManager.shared.adRewardPointFinal
                    GameManager.shared.addPoint(point: bonusPoint.finalPoint) { (isSucess) in
                        if isSucess {
                            UIApplication.shared.lastViewController?.alertBonusPoint(bonus: bonusPoint) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                    adcomplete()
                                }
                            }
                        }
                    }
                } else {
                    Toast.makeToast(message: "The network connection is unstable. Please try again later.".localized)
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


extension GameManager {
    /** 구독 설정에 따라 보너스 포인트 배율 정하기*/
    fileprivate var adRewordPointMultipleValue:Int {
        var bonus = 1
        for id in InAppPurchase.productIdSet {
            if let model = InAppPurchaseModel.model(productId: id) {
                if model.isExpire == false {
                    bonus *= Int.random(in: 3...10)
                }
            }
        }
        return bonus
    }
    
    /** 보너스 포인트를 곱한 리워드 포인트*/
    var adRewardPointFinal:BonusPoint {
        BonusPoint(point: AdminOptions.shared.adRewardPoint, bonusMultiple: adRewordPointMultipleValue)
    }        
}
