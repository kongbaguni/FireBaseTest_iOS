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
        UIColor(named: "indicatorColor") ?? .clear
    }
    
    open class var autoColor_bg_color:UIColor {
        UIColor(named: "normalBGColor") ?? .clear
    }
    
    open class var autoColor_text_color : UIColor {
        UIColor(named: "textColor") ?? .clear
    }
    
    open class var autoColor_bold_text_color : UIColor {
        UIColor(named: "boldTextColor") ?? .clear
    }
    
    open class var autoColor_weak_text_color : UIColor {
        UIColor(named: "weakTextColor") ?? .clear
    }
    
    open class var autoColor_switch_color : UIColor {
       UIColor(named:"switchColor") ?? .clear
    }
    
    open class var autoColor_launch_bg_color : UIColor {
        UIColor(named: "launchBGColor") ?? .clear
    }

}
