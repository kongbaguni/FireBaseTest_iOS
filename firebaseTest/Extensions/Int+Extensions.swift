//
//  Int+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation

extension Int {
    var decimalForamtString:String {
        return NumberFormatter.localizedString(from: NSNumber(value: self), number: .decimal)
    }
}
