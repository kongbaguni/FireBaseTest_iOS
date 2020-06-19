//
//  Locale+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/21.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
extension Locale {
    static var preferredLocale:Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
    
    static var preferredLocales:[Locale] {
        var locales:[Locale] = []
        for language in Locale.preferredLanguages {
            locales.append(Locale(identifier: language))
        }
        if locales.count == 0 {
            return [Locale.current]
        }
        return locales
    }
    
    var isKoreanLocale:Bool {
        return identifier == "ko-Kore_KR" || identifier == "ko" || identifier == "ko_KR"
    }
}
