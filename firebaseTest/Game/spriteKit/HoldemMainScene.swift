//
//  HoldemMainScene.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SpriteKit
class HoldemMainScene: SKScene {
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        playSound(audioNode: .bgm1, isAutoPlayLoop: true)
        let cards = GameManager.shared.popCards(number: 3)
        let card = CardNode(card: cards.first!)
        addChild(card)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            card.flip()
        }
        
    }
}
