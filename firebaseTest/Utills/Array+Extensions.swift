//
//  Array+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/31.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
extension Array {
    /** 배열을 콤마로 구분하는 문자열로 변환*/
    var stringValue:String {
        var result = ""
        for item in self {
            if result.isEmpty == false {
                result.append(",")
            }
            if let str = (item as? URL)?.absoluteString {
                result.append(str)
            }
            else if let str = item as? String {
                result.append(str)
            }
        }
        return result
    }
    
}
