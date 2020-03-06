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
        get {
            if UIApplication.shared.isDarkMode {
                return .white
            }
            else {
                return .black
            }
        }
    }
}
