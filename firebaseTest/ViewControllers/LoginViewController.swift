//
//  LoginViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import AlamofireImage

class LoginViewController: UIViewController {
    class var viewController : LoginViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "first") as! LoginViewController
    }
    @IBOutlet weak var loginGoogleBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        if UserInfo.info != nil {
            view.isHidden = true
        }
        let icon =
        #imageLiteral(resourceName: "google").af_imageAspectScaled(toFit: CGSize(width: 50, height: 50))
        loginGoogleBtn.setImage(icon, for: .normal)
    }
    
    @IBAction func onTouchupLoginGoogleBtn(_ sender:UIButton) {
        GIDSignIn.sharedInstance().signIn()

    }
}
