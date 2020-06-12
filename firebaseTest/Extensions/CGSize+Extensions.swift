//
//  CGSize+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
extension CGSize {
    fileprivate func isOver(target:CGSize)->Bool {
        return width > target.width || height > target.height
    }
    
    func resize(target:CGSize, isFit:Bool)->CGSize {
        let sizea = CGSize(width: target.width, height: height * (target.width / width))
        let sizeb = CGSize(width: width * (target.height / height), height: target.height)

        if isFit {
            for size in [sizea, sizeb] {
                if size.isOver(target: target) == false {
                    return size
                }
            }
        }
        else {
            for size in [sizea, sizeb] {
                if size.isOver(target: target) {
                    return size
                }
            }
        }
        return sizeb
    }
}

func *(left:CGSize,right:CGFloat)->CGSize {
    let w = left.width * sqrt(right)
    let h = left.height * sqrt(right)
    return CGSize(width: w , height: h)
}

func /(left:CGSize,right:CGFloat)->CGSize {
    let w = left.width / sqrt(right)
    let h = left.height / sqrt(right)
    return CGSize(width: w , height: h)
}
