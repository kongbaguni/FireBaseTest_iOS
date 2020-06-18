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
    let dealar = PlayerDeckNode(texture: nil, color: .blue, size: CGSize(width: 300, height: 120))
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
                
//        playSound(audioNode: .bgm1, isAutoPlayLoop: true)
        
        let topLeft = CGPoint(x:-UIScreen.main.bounds.width/2,
                              y:UIScreen.main.bounds.height/2)
        
        cardDeck.position = topLeft + CGPoint(x: 60, y: -120)
        addChild(cardDeck)
        
        dealar.position = topLeft + CGPoint(x: 80,y: -300)
        addChild(dealar)
        
        insertCard(target: dealar, deadLine: .now() + .milliseconds(0))
        insertCard(target: dealar, deadLine: .now() + .milliseconds(1000))
        
        flipAllCards(target: dealar, deadLine: .now() + .seconds(10))
    }
    
    func insertCard(target:PlayerDeckNode, deadLine:DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: deadLine) {
            self.cardDeck.popCard { (card) in
                target.insertCard(card: card)
            }
        }
    }
    
    func flipAllCards(target:PlayerDeckNode, deadLine:DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: deadLine) {
            target.flipAllCards()
        }
    }
}
