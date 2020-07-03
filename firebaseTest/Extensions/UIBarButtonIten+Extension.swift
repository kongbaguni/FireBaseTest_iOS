//
//  UIBarButtonIten+Extension.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/07/03.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
extension UIBarButtonItem {
    open class func closeButton(target:Any?,selector:Selector?)->UIBarButtonItem {
        if #available(iOS 13.0, *) {
            return UIBarButtonItem(barButtonSystemItem: .close, target: target, action: selector)
        } else {
            return UIBarButtonItem(title: "close".localized, style: .plain, target: target, action: selector)
        }
    }
    
    open class func saveButton(target:Any?,selector:Selector?)->UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .save, target: target, action: selector)
    }
}
