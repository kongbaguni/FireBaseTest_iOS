//
//  SKView+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SpriteKit

extension SKScene {
    func playSound(audioNode:SKAudioNode, isAutoPlayLoop:Bool = false) {        
        if audioNode.parent != scene {
            addChild(audioNode)
        }
        audioNode.autoplayLooped = isAutoPlayLoop
        if isAutoPlayLoop == false {
            audioNode.run(.play())
        }
    }
}
