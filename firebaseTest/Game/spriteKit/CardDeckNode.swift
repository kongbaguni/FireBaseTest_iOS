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
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: .clear, size: size)
        
        for (index,cardInfo) in GameManager.shared.cardDeck.enumerated() {
            let cardNode = CardNode(card: cardInfo)
            addChild(cardNode)
            cardNode.run(.move(to: CGPoint(x: CGFloat(index) * 2 , y: 0), duration: 0.2))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
