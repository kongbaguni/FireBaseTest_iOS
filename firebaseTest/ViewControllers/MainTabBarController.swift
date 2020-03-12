//
//  MainTabBarController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
class MainTabBarController: UITabBarController {
    class var viewController:MainTabBarController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mainTabBar") as! MainTabBarController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = tabBar.items {
            items[0].title = "mask now".localized
            items[0].image = #imageLiteral(resourceName: "dentist-mask").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))
            items[1].title = "todays talks".localized
            items[1].image = #imageLiteral(resourceName: "talkBubble").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))
        }
    }
}
