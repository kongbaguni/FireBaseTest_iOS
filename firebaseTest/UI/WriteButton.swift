//
//  WriteButton.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/07/01.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

extension UIButton {
    open class var writeButton:UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(#imageLiteral(resourceName: "write_n"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "write_s"), for: .highlighted)
        return button
    }
}
