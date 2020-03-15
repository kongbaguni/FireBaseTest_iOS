//
//  String+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/03.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import PhoneNumberKit
import CommonCrypto

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



extension String {
    /** 다국어 번역 지원 */
    var localized:String {
        let value = NSLocalizedString(self, comment:"")
        return value
    }
    
    /** base64 로 디코딩 된 이미지 얻어오기 */
    var base64decodingUIImage:UIImage? {
        guard let imageData = Data(base64Encoded: self) else {
            return nil
        }
        guard let img = UIImage(data: imageData) else {
            return nil
        }
        return img
    }

    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}


extension String {
    var sha256:String {
        func digest(input : NSData) -> NSData {
            let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
            var hash = [UInt8](repeating: 0, count: digestLength)
            CC_SHA256(input.bytes, UInt32(input.length), &hash)
            return NSData(bytes: hash, length: digestLength)
        }
        
        func hexStringFromData(input: NSData) -> String {
            var bytes = [UInt8](repeating: 0, count: input.length)
            input.getBytes(&bytes, length: input.length)
            
            var hexString = ""
            for byte in bytes {
                hexString += String(format:"%02x", UInt8(byte))
            }
            return hexString
        }
        
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }

    var sha512:String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        if let data = data(using: String.Encoding.utf8) {
            let value =  data as NSData
            CC_SHA512(value.bytes, CC_LONG(data.count), &digest)

        }
        var digestHex = ""
        for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}

extension String {
    var base64DecodedData:NSData? {
        return NSData(base64Encoded: self)
    }
}


extension String {
    enum PasscodeTest {
        /** 유효함*/
        case valid
        /** 같은 숫자 3자리이상 연속됨*/
        case same
        /** 3자리 이상 연속 증가*/
        case up
        /** 3자리 이상 연속 감소*/
        case down
    }
    /** 페스워드 유효성 검사. 0 = 정상 1 = 동일숫자연속 2 = 증가하는 숫자 3자리 이상 , 3 = 감소하는 숫자 3자리 이상*/
    var validPasswordCode:PasscodeTest {
        var list:[Int] = []
        var count = 0
        var sameCount = 0
        var successiveCountDesc = 0
        var successiveCountAsc = 0
        for char in self {
            var last:Int? = nil
            if list.count > 1 {
                last = list.last
            }
            let new = NSString(string: "\(char)").integerValue
            if let l = last {
                if l == new { sameCount += 1} else { sameCount = 0}
                if l - new == 1 { successiveCountAsc += 1 } else { successiveCountAsc = 0 }
                if l - new == -1 { successiveCountDesc += 1} else { successiveCountDesc = 0 }
            }
            if sameCount >= 2 {
                return .same
            }
            if successiveCountDesc >= 2 {
                return .up
            }
            if successiveCountAsc >= 2 {
                return .down
            }

            list.append(new)
            count += 1
        }
        return .valid
    }
        
}


extension String {
    func dateValue(format:String)->Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    /** 앞뒤로 공백및 줄바꾸기 제거*/
    var trimForPostValue:String {
        func trim(_ value:String)->String {
            return self.replacingOccurrences(of: "    ", with: " ")
            .replacingOccurrences(of: "   ", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: "\n\n\n\n\n", with: "\n\n")
            .replacingOccurrences(of: "\n\n\n\n", with: "\n\n")
            .replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        
        let value = self.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        return trim(trim(value))
    }
    
}
