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
            items[1].title = "todays talks".localized
        }
    }
}
