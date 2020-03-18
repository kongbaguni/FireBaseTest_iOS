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
            self?.setCards()
        }
        isSetNotification = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCards()
    }
    
    func setCards() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        for i in 0...GameManager.shared.deckBoxCardsCount {
            let view = UIImageView(image: #imageLiteral(resourceName: "gray_back"))
            view.frame.size = CGSize(width: 40, height: 70)
            view.frame.origin = CGPoint(x: i*3, y: 0)
            addSubview(view)
        }
    }
}
