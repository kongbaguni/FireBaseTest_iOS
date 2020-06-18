//
//  CGPoint+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
func +(left:CGPoint,right:CGPoint)->CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left:CGPoint,right:CGPoint)->CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
