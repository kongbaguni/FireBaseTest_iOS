//
//  MainNavigationController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
class MainNavigationController: UINavigationController {
    deinit {
        debugPrint("deinit \(#file)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.userInfo == nil {
            viewControllers = [PhoneAuthViewController.viewController]
        }
        else {
            viewControllers = [MainViewController.viewController]
        }
    }
    
}
