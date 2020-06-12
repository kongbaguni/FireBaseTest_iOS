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
    let cardDeck = CardDeckNode(texture: nil, color: .white, size: CGSize(width: 300, height: 120))
    override func didMove(to view: SKView) {
        super.didMove(to: view)
                
        playSound(audioNode: .bgm1, isAutoPlayLoop: true)
        addChild(cardDeck)
        
    }
}
