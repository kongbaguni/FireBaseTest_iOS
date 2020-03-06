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
import NVActivityIndicatorView

class LoginViewController: UIViewController {
    @IBOutlet weak var autologinBgView: UIView!
    class var viewController : LoginViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "first") as! LoginViewController
    }
    @IBOutlet weak var loginGoogleBtn:UIButton!
    let indicator = NVActivityIndicatorView(
        frame: UIScreen.main.bounds,
        type: .ballRotateChase,
        color: .indicator_color,
        padding: UIScreen.main.bounds.width)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        autologinBgView.isHidden = UserInfo.info == nil
        view.addSubview(indicator)
        if UserInfo.info != nil {
            indicator.startAnimating()
        }
        
        let icon =
        #imageLiteral(resourceName: "google").af_imageAspectScaled(toFit: CGSize(width: 50, height: 50))
        loginGoogleBtn.setImage(icon, for: .normal)
    }
    
    @IBAction func onTouchupLoginGoogleBtn(_ sender:UIButton) {
        GIDSignIn.sharedInstance().signIn()

    }
}
