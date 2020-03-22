//
//  CardDeckBoxView.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
class CardDeckBoxView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setNotification()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setNotification()
    }

    var isSetNotification = false
    func setNotification() {
        if isSetNotification {
            return
        }
        NotificationCenter.default.addObserver(forName: .game_popCardFromCardDeckBox, object: nil, queue: nil) { [weak self](notification) in
            if let count = notification.object as? Int , let sviewCount = self?.subviews.count {
                self?.removeCards(cardCount: sviewCount - count )
            }
            
        }
        isSetNotification = true
        setCards()
    }
    
    
    func setCards() {
        for view in self.subviews {
            view.removeFromSuperview()
        }        
        for i in 0...GameManager.shared.deckBoxCardsCount {
            let view = UIImageView(image: #imageLiteral(resourceName: "gray_back"))
            view.frame.size = CGSize(width: 40, height: 70)
            view.frame.origin = CGPoint(x: i*5, y: 0)
            addSubview(view)
        }
    }
    
    func removeCards(cardCount:Int) {
        if self.subviews.count < cardCount || cardCount == 0 {
            setCards()
            return
        }
        let sc = self.subviews.count
        var aniView:[UIView] = []
        for i in 1..<cardCount {
            aniView.append(self.subviews[sc-i])
        }
        for view in aniView {
            UIView.animate(withDuration: 0.1, animations: {
                view.frame.origin.x += 100
                view.alpha = 0
            }) { (fin) in
                if fin {
                    view.removeFromSuperview()
                }
            }
        }

    }
}
