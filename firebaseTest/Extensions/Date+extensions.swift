//
//  Date+extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
extension Date {
    var simpleFormatStringValue:String {
        DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .short)
    }
    
    /** 지금 시각 기준 상대 시각 표시.*/
    var relativeTimeStringValue:String {
        let interval = Date().timeIntervalSince1970 - timeIntervalSince1970
        if interval < 60 {
            return "just now".localized
        }
        
        if interval < 60 * 60 {
            let m = "\(Int(interval / 60))"
            return String(format: "%@ minutes ago".localized, m)
        }
        
        if interval < 60 * 60 * 24 {
            let h = "\(Int(interval / (60 * 60)))"
            return String(format: "%@ hour ago".localized, h)
        }
        
        if interval < 60 * 60 * 24 * 2 {
            return "Yesterday".localized
        }
        
        if interval < 60 * 60 * 24 * 3 {
            return "Day before yesterday".localized
        }
        
        if interval < 60 * 60 * 24 * 30 {
            let h = "\(Int(interval / (60 * 60 * 24)))"
            return String(format: "%@ days ago".localized, h)
        }
        
        return DateFormatter.localizedString(from: self, dateStyle: .long, timeStyle: .none)
    }
}
