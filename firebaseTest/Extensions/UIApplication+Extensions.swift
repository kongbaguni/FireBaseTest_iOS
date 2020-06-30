//
//  UIApplication+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
extension UIApplication {
    var isDarkMode:Bool {        
        if #available(iOS 12.0, *) {
            return windows.first?.rootViewController?.traitCollection.userInterfaceStyle == .dark
        }
        return false
    }
    
    var lastViewController:UIViewController? {
        if var vc = windows.first?.rootViewController {
            while vc.presentedViewController != nil {
                vc = vc.presentedViewController!
            }
            return vc
        }
        return nil
    }
    
    /** 홈 버튼 눌러서 빠져나오기와 똑같은 동작을 합니다. 프로그램 종료 코드는 reject 사유가 될 수 있으므로. 이 코드를 사용합니다.*/
    func goHome() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
    
    var version:String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    var rootViewController:UIViewController? {
        get {
            if #available(iOS 13.0, *) {
                return UIApplication.shared.windows.first?.rootViewController
            } else {
                return UIApplication.shared.keyWindow?.rootViewController
            }
        }
        set {
            if #available(iOS 13.0, *) {
                UIApplication.shared.windows.first?.rootViewController = newValue
            } else {
                UIApplication.shared.keyWindow?.rootViewController = newValue
            }

        }
    }
    
}
