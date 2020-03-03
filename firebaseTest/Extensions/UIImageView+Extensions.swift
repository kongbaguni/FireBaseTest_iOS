//
//  UIImageView+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/03.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import Kingfisher
extension UIImageView {
    func setImage(image:UIImage?, placeHolder:UIImage!) {
        self.image = placeHolder
        if let img = image {
            self.image = img
        }
    }
    
    func setImageUrl(url:String?, placeHolder:UIImage!) {
        if let str = url {
            let url = URL(string: str)
            kf.setImage(with: url, placeholder: placeHolder)
        } else {
            image = placeHolder
        }
    }
}
