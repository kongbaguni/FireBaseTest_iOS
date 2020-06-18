//
//  CardDeckNode.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SpriteKit
class CardDeckNode: SKSpriteNode {
    var cards:[CardNode] {
        var cards:[CardNode] = []
        for node in children {
            if let n = node as? CardNode {
                if n.isPop == false {
                    cards.append(n)
                }
            }
        }
        return cards
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: .clear, size: size)
        insertCards()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertCards() {
        let cards = GameManager.shared.popCards(number:100)
        
        var index = 0
        for cardInfo in cards {
            let cardNode = CardNode(card: cardInfo)
            addChild(cardNode)
            cardNode.run(.move(to: CGPoint(x: CGFloat(index) * 2 , y: 0), duration: 0.2))
            index += 1
        }
    }
    
    func popCard(popCard: @escaping(_ popCard:CardNode)->Void) {
        if cards.count == 0 {
            insertCards()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.popCard(popCard: popCard)
            }
            return
        }

        if let card = cards.last {
            card.isPop = true
            card.run(.move(by: CGVector(dx: 200, dy: 0), duration: 0.5))
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                card.removeFromParent()
                popCard(card)
            }
        }
    }
}
