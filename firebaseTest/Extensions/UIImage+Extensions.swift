//
//  UIImage+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/27.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

extension UIImage {
    open class var closeBtnImage_normal:UIImage {
        if #available(iOS 13.0, *) {
            return #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
                    .withTintColor(.autoColor_text_color)
        } else {
            return #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        }
    }
    
    open class var closeBtnImage_highlighted:UIImage {
        if #available(iOS 13.0, *) {
            return #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
                    .withTintColor(.autoColor_weak_text_color)
        } else {
            return #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        }
    }

    
}
