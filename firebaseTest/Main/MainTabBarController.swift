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
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mainTabBar") as! MainTabBarController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabBar") as! MainTabBarController
        }
    }

    struct Item {
        let viewController:UIViewController
        let title:String
        let image:UIImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserInfo.info?.syncData(complete: { (sucess) in
            UserInfo.syncUserInfo {
                
            }
        })
        var items:[Item] = [
            Item(viewController: ReviewsViewController.viewController,
                 title: "review".localized,
                 image: #imageLiteral(resourceName: "review")),
            Item(viewController: TodaysTalksTableViewController.viewController,
                 title: "todays talks".localized,
                 image: #imageLiteral(resourceName: "talkBubble")),
            Item(viewController: RankingTableViewController.viewController,
                 title: "ranking".localized,
                 image: #imageLiteral(resourceName: "Leaderboard"))
        ]
        if AdminOptions.shared.maskNowEnable {
            let item = Item(viewController: StoresTableViewController.viewController,
                 title: "Mask now".localized,
                 image: #imageLiteral(resourceName: "dentist-mask"))
            items.insert(item, at: 0)
        }
        
        var viewControllers:[UIViewController] = []
        for item in items {
            viewControllers.append(UINavigationController(rootViewController: item.viewController))
        }
        self.viewControllers = viewControllers
        
        for (index, item) in items.enumerated() {
            tabBar.items?[index].title = item.title
            tabBar.items?[index].image = item.image.af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))
        }

    }
}
