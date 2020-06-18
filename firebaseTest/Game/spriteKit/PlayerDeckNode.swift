//
//  DealarNode.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SpriteKit
class PlayerDeckNode: SKSpriteNode {
    var cards:[CardNode] {
        var cards:[CardNode] = []
        for node in children {
            if let n = node as? CardNode {
                cards.append(n)
            }
        }
        return cards
    }
    
    func insertCard(card:CardNode) {
        addChild(card)
        card.run(.move(to: .zero + CGPoint(x: 100 * (cards.count-1), y: 0), duration: 0.5))
    }
    
    func flipAllCards() {
        for card in cards {
            card.flip()
        }
    }
}
