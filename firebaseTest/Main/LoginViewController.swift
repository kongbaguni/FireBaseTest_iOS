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
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var loginAppleBtn: UIButton!
    @IBOutlet weak var loginGoogleBtn:UIButton!
    @IBOutlet weak var maskNowBtn: UIButton!

    class var viewController : LoginViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "first") as! LoginViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "first") as! LoginViewController
        }
    }
    
    

    let loading = Loading()
    
    var signApple:SigninWithApple! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signApple = SigninWithApple(controller: self)
        print("\(#file) \(#function)")
        GIDSignIn.sharedInstance()?.presentingViewController = self
        setUI()
        versionLabel.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            UIView.animate(withDuration: 0.5) {
                self?.versionLabel.alpha = 1
            }
        }
    }
    
    func setUI() {
        titleLabel.text = "app title".localized
        maskNowBtn.setTitle("mask now".localized, for: .normal)
        loginGoogleBtn.setTitle("login with google".localized, for: .normal)
        loginAppleBtn.setTitle("login with Apple".localized, for: .normal)
        autologinBgView.isHidden = UserInfo.info == nil
        if UserInfo.info != nil {
            loading.show(viewController: self)
        }
        titleLabel.textColor = .autoColor_text_color
        titleBubbleImageView.image = .bubble
        for view in [titleImageView,centerImageView] {
            view?.tintColor = .autoColor_text_color
            view?.image = #imageLiteral(resourceName: "review").withRenderingMode(.alwaysTemplate)
        }
        //버튼 이미지 설정하기
        func setBtnImage(btn:UIButton, image:UIImage) {
            btn.setImage(image, for: .normal)
            btn.setImage(image.withRenderingMode(.alwaysTemplate), for: .highlighted)
            btn.tintColor = .autoColor_bold_text_color
        }
        
        //구글 로그인 버튼 설정
        let googleicon = #imageLiteral(resourceName: "google").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))
        setBtnImage(btn: loginGoogleBtn, image: googleicon)
        
        //애플 로그인 버튼 설정
        if #available(iOS 13.0, *) {
            let appleicon = #imageLiteral(resourceName: "apple").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withTintColor(.autoColor_text_color)
            setBtnImage(btn: loginAppleBtn, image: appleicon)
            loginAppleBtn.isHidden = false
        } else {
            loginAppleBtn.isHidden = true
        }
        
        //마스크나우 버튼 설정.
        if #available(iOS 13.0, *) {
            let maskIcon = #imageLiteral(resourceName: "dentist-mask").af.imageAspectScaled(toFit: CGSize(width:30,height:30))
                .withRenderingMode(.alwaysTemplate).withTintColor(.autoColor_text_color)
            maskNowBtn.setImage(maskIcon, for: .normal)
        } else {
            let maskIcon = #imageLiteral(resourceName: "dentist-mask").af.imageAspectScaled(toFit: CGSize(width:30,height:30))
                .withRenderingMode(.alwaysTemplate)
            maskNowBtn.setImage(maskIcon, for: .normal)
        }
        
        versionLabel.text = "ver : \(UIApplication.shared.version)"
    }
    
    override func viewDidLayoutSubviews() {
        for btn in [loginAppleBtn, loginGoogleBtn] {
            btn?.backgroundColor = .autoColor_bg_color
            btn?.setBackgroundImage(UIImage(color: .clear, size: CGSize(width: 100, height: 100)), for: .normal)
            btn?.setBackgroundImage(UIImage(color: .gray, size: CGSize(width: 100, height: 100)), for: .highlighted)
            btn?.setBorder(borderColor: .clear, borderWidth: 0.0, radius: 10, masksToBounds: true)
            btn?.setTitleColor(.autoColor_text_color, for: .normal)
            btn?.setTitleColor(.autoColor_bold_text_color, for: .highlighted)
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
