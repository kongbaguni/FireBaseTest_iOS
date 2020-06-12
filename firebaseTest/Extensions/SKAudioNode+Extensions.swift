//
//  SKAudioNode+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SpriteKit

extension SKAudioNode {
    open class var effect1:SKAudioNode {
        let node = SKAudioNode(url: Bundle.main.url(forResource: "effect1", withExtension: "mp3")!)
        node.autoplayLooped = false        
        return node
    }
    
    open class var bgm1:SKAudioNode {
        let node = SKAudioNode(url: Bundle.main.url(forResource: "BGM1", withExtension: "mp3")!)
        node.autoplayLooped = true
        return node

    }
}
