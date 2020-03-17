//
//  UIColor+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
extension UIColor {
    open class var autoColor_indicator_color: UIColor {
        UIApplication.shared.isDarkMode ? .white : .black
    }
    
    open class var autoColor_bg_color:UIColor {
        UIApplication.shared.isDarkMode ? .black : .white
    }
    
    open class var autoColor_text_color : UIColor {
        UIApplication.shared.isDarkMode ? .white : .black
    }
    
    open class var autoColor_bold_text_color : UIColor {
        UIApplication.shared.isDarkMode
            ? .yellow
            : UIColor(red: 0.2, green: 0.3, blue: 0.9, alpha: 1)
    }
    open class var autoColor_weak_text_color : UIColor {
        UIApplication.shared.isDarkMode
            ? UIColor(white: 0.4, alpha: 1)
            : UIColor(white: 0.6, alpha: 1)
    }
    
    open class var autoColor_switch_color : UIColor {
        UIApplication.shared.isDarkMode
            ? UIColor(red: 0.9, green: 0.6, blue: 0.3, alpha: 1)
            : UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1)
    }

}
