//
//  Array+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/09.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
extension Array {
    /** 콤마로 구분된 string 값 출력*/
    var stringValue:String {
        var result = ""
        for item in self {
            if result.isEmpty == false {
                result += ","
            }
            if let str = item as? String {
                result += str
            }
        }
        return result
    }
}
