//
//  String+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/03.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import PhoneNumberKit

extension String {
    fileprivate var phoneNumber:PhoneNumber? {
        let pk = PhoneNumberKit()
        do {
            return try pk.parse(self)
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }
    
    func phoneNumberFormat(format:PhoneNumberFormat)->String? {
        if let number = phoneNumber {
            let pk = PhoneNumberKit()
            return pk.format(number, toType: format)
        }
        return nil
    }
}
