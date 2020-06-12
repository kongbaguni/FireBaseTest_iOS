//
//  HoldemIntroScene.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SpriteKit
class HoldemIntroScene: SKScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        playSound(audioNode: .effect1)
    }
    
}
