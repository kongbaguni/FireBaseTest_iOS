//
//  TermViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/29.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import FirebaseAuth
import RxCocoa
import RxSwift

class TermViewController: UIViewController {
    static var viewController:TermViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "term")
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "term") as! TermViewController
        }
    }
    var authResult:AuthDataResult? = nil
    var idTokenString:String = ""
    var accessToken:String = ""
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var agreeBtn1:UIButton!
    @IBOutlet weak var agreeBtn2:UIButton!
    @IBOutlet weak var agreeBtn3:UIButton!
    @IBOutlet var titleLabels:[UILabel]!
    @IBOutlet var webviews:[WKWebView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url1 = Bundle.main.url(forResource: "term", withExtension: "html"),
            let url2 = Bundle.main.url(forResource: "privacyPolicy", withExtension: "html")
            else {
            return
        }
        let urls = [url1,url2]
        let titles = ["term","privacyPolicy"]
        
        for (index,view) in webviews.enumerated() {
            view.navigationDelegate = self
            view.alpha = 0
            view.load(URLRequest(url: urls[index]))
            titleLabels[index].text = titles[index].localized
        }
                
        for btn in [agreeBtn1, agreeBtn2] {
            btn?.setTitle("agree msg".localized, for: .normal)
            btn?.rx.tap.bind { [weak btn, weak self](_) in
                btn?.isSelected.toggle()
                self?.check()
            }.disposed(by: disposeBag)
        }
        agreeBtn3.setTitle("agree all msg".localized, for: .normal)
        agreeBtn3.rx.tap.bind { [weak self](_) in
            guard let a = self?.agreeBtn1,
                let b = self?.agreeBtn2,
                let c = self?.agreeBtn3 else {
                return
            }
            c.isSelected.toggle()
            a.isSelected = c.isSelected
            b.isSelected = c.isSelected
            self?.check()
        }.disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeDisplyStyleWebview()
    }
    
    func changeDisplyStyleWebview() {
        for view in webviews {
            view.setBorder(borderColor: .autoColor_text_color, borderWidth: 0.5)
            
            view.evaluateJavaScript("changeMode('\(UIApplication.shared.isDarkMode ? "dark" : "light")')", completionHandler: { (_, error) in
                
            })
        }
    }
    
    func check() {
        if agreeBtn1.isSelected == true && agreeBtn2.isSelected == true {
            gotoProfile()
        }
    }
    
    func gotoProfile() {
        print(authResult?.name ?? "이름 없음")
        authResult?.saveUserInfo(idToken: idTokenString, accessToken: accessToken) { [weak self] _ in
            StoreModel.deleteAll()
            AdminOptions.shared.getData {
                let vc = MyProfileViewController.viewController
                vc.hideLeaveCell = true
                vc.authDataResult = self?.authResult
                UIApplication.shared.rootViewController = UINavigationController(rootViewController: vc)
            }
        }
    }
}

extension TermViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        changeDisplyStyleWebview()
        UIView.animate(withDuration: 0.25) {
            webView.alpha = 1
        }
        webView.evaluateJavaScript("document.getElementsByTagName('title')[0].innerText") {[weak self] (result, error) -> Void in
            if let txt = result as? String {
                for (index,view) in (self?.webviews ?? []).enumerated() {
                    if view == webView {
                        self?.titleLabels[index].text = txt
                        return
                    }
                }
            }
        }
    }
}
