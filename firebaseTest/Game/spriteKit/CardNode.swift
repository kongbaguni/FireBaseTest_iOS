//
//  CardNode.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SpriteKit
class CardNode: SKSpriteNode {
    var card:Card? = nil
    init(card:Card) {
        self.card = card
        super.init(texture: SKTexture(image: #imageLiteral(resourceName: "green_back")),color:.white, size:#imageLiteral(resourceName: "green_back").size * 0.1)
          
    }
//    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
//        super.init(texture: SKTexture(image: #imageLiteral(resourceName: "green_back")),color:.white, size:#imageLiteral(resourceName: "green_back").size * 0.1)
//    }
    
    func flip() {
        guard let image = card?.image else {
            return
        }
        run(.sequence([
            .rotate(byAngle: CGFloat(Double.pi), duration: 0.2),
            .setTexture(SKTexture(image:image))
        ]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
