//
//  UIColor+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
extension UIColor {
    open class var indicator_color: UIColor {
        UIApplication.shared.isDarkMode ? .white : .black
    }
    
    open class var bg_color:UIColor {
        UIApplication.shared.isDarkMode ? .black : .white
    }
    
    open class var text_color : UIColor {
        UIApplication.shared.isDarkMode ? .white : .black
    }
    
    open class var bold_text_color : UIColor {
        UIApplication.shared.isDarkMode ? .yellow : .blue
    }
}
