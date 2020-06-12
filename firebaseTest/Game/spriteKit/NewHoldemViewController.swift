//
//  NewHoldemViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class NewHoldemViewController: UIViewController {
    static var viewController : NewHoldemViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Holdem", bundle: nil).instantiateViewController(identifier: "root") as! NewHoldemViewController
        } else {
            return UIStoryboard(name: "Holdem", bundle: nil).instantiateViewController(withIdentifier: "root") as! NewHoldemViewController
        }
    }
    
    var skView:SKView? {
        return view as? SKView
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        skView?.presentScene(.holdemIntro)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.skView?.presentScene(.holdemMain, transition: .crossFade(withDuration: 1))
        }
        
    }
}
 
