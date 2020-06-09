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
    @IBOutlet weak var autologinBgView:UIView!
    @IBOutlet weak var titleBubbleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    
    class var viewController : LoginViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "first") as! LoginViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "first") as! LoginViewController
        }
    }
    
    @IBOutlet weak var loginAppleBtn: UIButton!
    @IBOutlet weak var loginGoogleBtn:UIButton!
    @IBOutlet weak var maskNowBtn: UIButton!
    

    let loading = Loading()
    
    var signApple:SigninWithApple! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signApple = SigninWithApple(controller: self)
        print("\(#file) \(#function)")
        titleLabel.text = "app title".localized
        maskNowBtn.setTitle("mask now".localized, for: .normal)
        loginGoogleBtn.setTitle("login with google".localized, for: .normal)
        loginAppleBtn.setTitle("login with Apple".localized, for: .normal)
        GIDSignIn.sharedInstance()?.presentingViewController = self
        autologinBgView.isHidden = UserInfo.info == nil
        
        if UserInfo.info != nil {
            loading.show(viewController: self)
        }
        
        titleBubbleImageView.image = .bubble
        
        let googleicon = #imageLiteral(resourceName: "google").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))
        loginGoogleBtn.setImage(googleicon, for: .normal)
        
        let appleicon = #imageLiteral(resourceName: "apple").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))
        loginAppleBtn.setImage(appleicon, for: .normal)
        
        if #available(iOS 13.0, *) {
            loginAppleBtn.isHidden = false
            let maskIcon = #imageLiteral(resourceName: "dentist-mask").af.imageAspectScaled(toFit: CGSize(width:30,height:30))
                .withRenderingMode(.alwaysTemplate).withTintColor(.autoColor_text_color)
            maskNowBtn.setImage(maskIcon, for: .normal)
        } else {
            loginAppleBtn.isHidden = true
            let maskIcon = #imageLiteral(resourceName: "dentist-mask").af.imageAspectScaled(toFit: CGSize(width:30,height:30))
                .withRenderingMode(.alwaysTemplate)
            maskNowBtn.setImage(maskIcon, for: .normal)
        }
        versionLabel.text = "ver : \(UIApplication.shared.version)"
        versionLabel.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            UIView.animate(withDuration: 0.5) {
                self?.versionLabel.alpha = 1
            }
        }
    }
    
    @IBAction func onTouchupLoginGoogleBtn(_ sender:UIButton) {
        switch sender {
        case loginGoogleBtn:
            GIDSignIn.sharedInstance().signIn()
        case loginAppleBtn:
            if #available(iOS 13.0, *) {
                signApple.startSignInWithAppleFlow()
            } else {
                
            }
            break
        default:
            break
        }
    }
}
