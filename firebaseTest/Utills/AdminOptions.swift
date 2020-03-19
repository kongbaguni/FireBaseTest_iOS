//
//  AdminOptions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseFirestore

/**  관리자가 원격으로 제어하는 옵션값 관리하는 클래스*/
class AdminOptions {
    static let shared = AdminOptions()
    
    /** 대기열 보고 위한 최소거리*/
    var waitting_report_distance : Int = Consts.WAITING_REPORT_DISTANCE

    /** 포커 */
    var isUsePorker: Bool = false
    
    /** 최대 베팅 포인트*/
    var maxBettingPoint: Int = 1000
    
    /** 최대 잭팟 포인트*/
    var maxJackPotPoint: Int = 999999
    
    /** 딜러가 0 포인트 베팅할 확률*/
    var dealarZeroPointBettingRate : Float = 0.1
    
    /** 딜러가 카드패와 상관없이 최대 배팅할 확률*/
    var dealarMaxBettingRate : Float = 0.2
    
    let collection = Firestore.firestore().collection("admin")
    
    var allData:[String:Any] {
        let data:[String:Any] = [
            "waitting_report_distance"  : waitting_report_distance,
            "isUsePorker"               : isUsePorker,
            "maxBettingPoint"           : maxBettingPoint,
            "maxJackPotPoint"           : maxJackPotPoint,
            "dealarZeroPointBettingRate": dealarZeroPointBettingRate,
            "dealarMaxBettingRate"      : dealarMaxBettingRate
        ]
        return data
    }
    
    func setData(key:String, value:String)->Bool {
        let intValue = NSString(string:value).integerValue
        if intValue > 0 {
            switch key {
            case "waitting_report_distance":
                waitting_report_distance = intValue
                return true
            case "maxBettingPoint":
                maxBettingPoint = intValue
                return true
            case "maxJackPotPoint":
                maxJackPotPoint = intValue
                return true
            default:
                break
            }
        }
        
        let floatValue = NSString(string: value).floatValue
        switch key {
        case "dealarZeroPointBettingRate":
            dealarZeroPointBettingRate = floatValue
            return true
        case "dealarMaxBettingRate":
            dealarZeroPointBettingRate = floatValue
            return true
        default:
            break
        }
        
        var boolValue = false
        switch value {
        case "true":
            boolValue = true
        case "false":
            boolValue = false
        default:
            return false
        }
        
        switch key {
        case "isUsePorker":
            isUsePorker = boolValue
            return true
        default:
            break
        }
        return false
    }
    
    func updateData(complete:@escaping(_ sucess:Bool)->Void) {
        collection.document("option").setData(allData) { (error) in
            complete(error == nil)
        }
    }
    
    func getData() {
        if let str = UserDefaults.standard.string(forKey: "adminOption") {
            if let data = Data(base64Encoded: str, options: .ignoreUnknownCharacters) {
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                    loadData(data: json)
                }
            }
        }
        
        let doc = collection.document("option")
        doc.getDocument { (snapshot, error) in
            if let doc = snapshot {
                doc.data().map { info in
                    self.loadData(data: info)
                    if let data = try? JSONSerialization.data(withJSONObject: info, options: .prettyPrinted) {
                        UserDefaults.standard.set(data.base64EncodedString(), forKey: "adminOption")
                    }
                }
            }
        }
    }
    
    private func loadData(data:[String:Any]) {
        isUsePorker = data["isUsePorker"] as? Bool ?? false
        waitting_report_distance = data["waitting_report_distance"] as? Int ?? Consts.WAITING_REPORT_DISTANCE
        maxBettingPoint = data["maxBettingPoint"] as? Int ?? 1000
        maxJackPotPoint = data["maxJackPotPoint"] as? Int ?? 999999
        dealarZeroPointBettingRate = data["dealarZeroPointBettingRate"] as? Float ?? 0.1
        dealarMaxBettingRate = data["dealarMaxBettingRate"] as? Float ?? 0.2
    }
}
