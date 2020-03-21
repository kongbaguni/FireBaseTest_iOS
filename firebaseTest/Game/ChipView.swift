//
//  ChipView.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/21.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
class ChipView: UIView {
    var isRightAlign = false
    var value:Int = 0 {
        didSet {
            for view in self.subviews {
                view.removeFromSuperview()
            }
            
            var a = self.value
            let chip50s = a / 50
            a -= chip50s * 50
            
            let chip10s = a / 10
            a -= chip10s * 10
            
            let chip5s = a / 5
            a -= chip5s * 5
            
            let chip1s = a
            print("total : \(self.value)")
            print("50 : \(chip50s)")
            print("10 : \(chip10s)")
            print("5 : \(chip5s)")
            print("1 : \(chip1s)")

            let chipSize = CGSize(width: 30, height: 30)
            
            let chipHeight:CGFloat = 2.5
            
            func makeChip(count:Int,image:UIImage)->[UIImageView] {
                var result:[UIImageView] = []
                for _ in 0..<count {
                    let view = UIImageView(image: image)
                    view.frame.size = chipSize
                    result.append(view)
                }
                return result
            }
            
            let sets = [
                makeChip(count: chip50s, image: #imageLiteral(resourceName: "chip50")),
                makeChip(count: chip10s, image: #imageLiteral(resourceName: "chip10")),
                makeChip(count: chip5s, image: #imageLiteral(resourceName: "chip5")),
                makeChip(count: chip1s, image: #imageLiteral(resourceName: "chip1"))
            ]
            var y:CGFloat = self.frame.height - chipSize.height

            
            if isRightAlign {
                var x:CGFloat = self.frame.width - chipSize.width
                for set in sets.reversed() {
                    if set.count > 0 {
                        for view in set {
                            view.frame.origin = CGPoint(x: x, y: y)
                            y -= chipHeight
                            self.addSubview(view)
                        }
                        x -= chipSize.width
                        y = self.frame.height - chipSize.height
                    }
                }
            }
            else {
                var x:CGFloat = 0
                for set in sets {
                    if set.count > 0 {
                        for view in set {
                            view.frame.origin = CGPoint(x: x, y: y)
                            y -= chipHeight
                            self.addSubview(view)
                        }
                        x += chipSize.width
                        y = self.frame.height - chipSize.height
                    }
                }
            }
            
        }
    }
    
    
}
