//
//  MainNavigationController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
class MainNavigationController: UINavigationController {
    class var viewController : MainNavigationController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mainNavigation") as! MainNavigationController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavigation") as! MainNavigationController
        }
    }
    
    deinit {
        debugPrint("deinit \(#file)")
    }

}
