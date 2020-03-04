//
//  FirstViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class FirstViewController: UIViewController {
    class var viewController : FirstViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "first") as! FirstViewController
    }
    @IBOutlet weak var loginGoogleBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        if UserInfo.info != nil {
            view.isHidden = true
        }
    }
    @IBAction func onTouchupLoginGoogleBtn(_ sender:UIButton) {
        GIDSignIn.sharedInstance().signIn()

    }
}
