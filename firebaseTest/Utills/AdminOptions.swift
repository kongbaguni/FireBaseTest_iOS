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
    fileprivate var isUsePoker: Bool = false
 
    /** 포커 할 수 있는 레벨 제한*/
    fileprivate var canUsePokerLevel: Int = 0
    
    var canPlayPoker:Bool {
        return isUsePoker && UserInfo.info?.level ?? 0 >= canUsePokerLevel
    }

    
    /** 최대 베팅 포인트*/
    var maxBettingPoint: Int = 1000
    
    /** 최대 잭팟 포인트*/
    var maxJackPotPoint: Int = 999999
    
    /** 최소 잭팟 포인트*/
    var minJackPotPoint: Int = 10000
    
    /** 딜러가 0 포인트 베팅할 확률*/
    var dealarZeroPointBettingRate : Float = 0.1
    
    /** 딜러가 카드패와 상관없이 최대 배팅할 확률*/
    var dealarMaxBettingRate : Float = 0.2

    /** 광고 1회 시청시 보상*/
    var adRewardPoint : Int = 500

    /** 포인트 소모 배율. 글자수 * n */
    var pointUseRatePosting : Int = 1
    /** 그림 올릴 떄 포인트 소모량 */
    var pointUseUploadPicture : Int = 100
    
    /** 최초 가입시 받은 포인트*/
    var defaultPoint : Int = 1000
    
    let collection = Firestore.firestore().collection(FSCollectionName.ADMIN)
    
    
    var allData:[String:Any] {
        let data:[String:Any] = [
            "waitting_report_distance"  : waitting_report_distance,
            "isUsePoker"                : isUsePoker,
            "maxBettingPoint"           : maxBettingPoint,
            "maxJackPotPoint"           : maxJackPotPoint,
            "minJackPotPoint"           : minJackPotPoint,
            "dealarZeroPointBettingRate": dealarZeroPointBettingRate,
            "dealarMaxBettingRate"      : dealarMaxBettingRate,
            "canUsePokerLevel"          : canUsePokerLevel,
            "adRewardPoint"             : adRewardPoint,
            "pointUseRatePosting"       : pointUseRatePosting,
            "pointUseUploadPicture"     : pointUseUploadPicture,
            "defaultPoint"              : defaultPoint
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
            case "minJackPotPoint":
                minJackPotPoint = intValue
                return true
            case "canUsePokerLevel":
                canUsePokerLevel = intValue
                return true
            case "adRewardPoint":
                adRewardPoint = intValue
                return true
            case "pointUseRatePosting":
                pointUseRatePosting = intValue
                return true
            case "pointUseUploadPicture":
                pointUseUploadPicture = intValue
                return true
            case "defaultPoint" :
                defaultPoint = intValue
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
        case "isUsePoker":
            isUsePoker = boolValue
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
    
    func getData(complete:@escaping()->Void) {
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
            complete()
        }
    }
    
    private func loadData(data:[String:Any]) {
        isUsePoker = data["isUsePoker"] as? Bool ?? false
        waitting_report_distance = data["waitting_report_distance"] as? Int ?? Consts.WAITING_REPORT_DISTANCE
        maxBettingPoint = data["maxBettingPoint"] as? Int ?? 1000
        maxJackPotPoint = data["maxJackPotPoint"] as? Int ?? 999999
        minJackPotPoint = data["minJackPotPoint"] as? Int ?? 10000
        dealarZeroPointBettingRate = data["dealarZeroPointBettingRate"] as? Float ?? 0.1
        dealarMaxBettingRate = data["dealarMaxBettingRate"] as? Float ?? 0.2
        canUsePokerLevel = data["canUsePokerLevel"] as? Int ?? 0
        adRewardPoint = data["adRewardPoint"] as? Int ?? 500
        pointUseUploadPicture = data["pointUseUploadPicture"] as? Int ?? 100
        pointUseRatePosting = data["pointUseRatePosting"] as? Int ?? 1
        defaultPoint = data["defaultPoint"] as? Int ?? 1000
    }
}
