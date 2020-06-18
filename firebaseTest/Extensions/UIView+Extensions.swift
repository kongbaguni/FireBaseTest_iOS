//
//  UIView+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/23.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

extension UIView {
    func setBorder(borderColor:UIColor, borderWidth:CGFloat, radius:CGFloat = 0, masksToBounds:Bool = true) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = radius
        layer.masksToBounds = masksToBounds
    }
    
    func setEmptyViewFrame() {
        frame = UIScreen.main.bounds
        frame.size.height -= (UIApplication.shared.statusBarFrame.height + 40)
    }
}
