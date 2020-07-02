//
//  AdminOptions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseFirestore

#if DEBUG
/** 대기열 보고 위한 거리제한*/

fileprivate let WAITING_REPORT_DISTANCE:Int = 500
#else
/** 대기열 보고 위한 거리제한*/
fileprivate let WAITING_REPORT_DISTANCE:Int = 50
#endif
fileprivate let MIN_BETTING_POINT = 10
fileprivate let MAX_BETTING_POINT = 50
fileprivate let MAX_JACKPOT_POINT = 99999
fileprivate let MIN_JACKPOT_POINT = 10000

fileprivate let D_ZERO_BETTING_RATE:Float = 0.1
fileprivate let D_MAX_BETTING_RATE:Float = 0.2
fileprivate let POKER_LEVEL_LIMIG = 0
fileprivate let AD_REWORD = 500
/** 작성글 로그 조회 가능한 레벨*/
fileprivate let CAN_VIEW_TALK_LOG_LEVEL = 10

fileprivate let POINT_USE_POSTING = 1
fileprivate let POINT_USE_IMAGE = 100

fileprivate let POINT_DEFAULT = 1000

fileprivate let EXP_FOR_REPORT_STOCK = 10
fileprivate let EXP_FOR_REPORT_WAIT = 10
fileprivate let EXP_FOR_REPORT_BAD = 10

fileprivate let POINT_FOR_REPORT_STOCK = 10
fileprivate let POINT_FOR_REPORT_WAIT = -10

/** 작성글 삭제를 위해 필요한 포인트*/
fileprivate let POINT_FOR_DELETE_TALK = 1000

/** 불량 게시물 신고를 위해 필요한 포인트*/
fileprivate let POINT_FOR_REPORT_BAD_POSTING = 100

/** 글쓰기 차단 해제 위해 필요한 포인트*/
fileprivate let POINT_FOR_UNBLOCK_POSTING = 1000000

/**  관리자가 원격으로 제어하는 옵션값 관리하는 클래스*/
class AdminOptions {
    
    static let shared = AdminOptions()
    
    /** 대기열 보고 위한 최소거리*/
    var waitting_report_distance : Int = WAITING_REPORT_DISTANCE
    
    /** 포커 */
    fileprivate var isUsePoker: Bool = false
    
    /** 포커 할 수 있는 레벨 제한*/
    fileprivate var canUsePokerLevel: Int = POKER_LEVEL_LIMIG
    
    var canPlayPoker:Bool {
        return isUsePoker && UserInfo.info?.level ?? 0 >= canUsePokerLevel
    }
    
    /** 최소 베팅 포인트*/
    var minBettingPoint: Int = MIN_BETTING_POINT
    /** 최대 베팅 포인트*/
    var maxBettingPoint: Int = MAX_BETTING_POINT
    
    /** 최대 잭팟 포인트*/
    var maxJackPotPoint: Int = MAX_JACKPOT_POINT
    
    /** 최소 잭팟 포인트*/
    var minJackPotPoint: Int = MIN_JACKPOT_POINT
    
    /** 딜러가 0 포인트 베팅할 확률*/
    var dealarZeroPointBettingRate : Float = D_ZERO_BETTING_RATE
    
    /** 딜러가 카드패와 상관없이 최대 베팅할 확률*/
    var dealarMaxBettingRate : Float = D_MAX_BETTING_RATE
    
    /** 광고 1회 시청시 보상*/
    var adRewardPoint : Int = AD_REWORD
    
    /** 포인트 소모 배율. 글자수 * n */
    var pointUseRatePosting : Int = POINT_USE_POSTING
    /** 그림 올릴 떄 포인트 소모량 */
    var pointUseUploadPicture : Int = POINT_USE_IMAGE
    
    /** 최초 가입시 받은 포인트*/
    var defaultPoint : Int = POINT_DEFAULT
    
    /** 다른 사용자의 작성글 이력을 조회할 수 있는 레벨*/
    var canViewTalkLogLevel : Int = CAN_VIEW_TALK_LOG_LEVEL
    
    let collection = FS.store.collection(FSCollectionName.ADMIN)
    
    var levelupReqExpBase = Consts.LEVELUP_REQ_EXP_BASE
    var levelupReqExpPlus = Consts.LEVELUP_REQ_EXP_PLUS
    
    var expForReportStoreStock = EXP_FOR_REPORT_STOCK
    var expForReportStoreWait = EXP_FOR_REPORT_WAIT
    var expForReportBadPosting = EXP_FOR_REPORT_BAD
    
    var pointForReportStoreStock = POINT_FOR_REPORT_STOCK
    var pointForReportStoreWait = POINT_FOR_REPORT_WAIT

    /** 글쓰기 차단 해제 위해 필요한 포인트*/
    var pointForUnblockPosting = POINT_FOR_UNBLOCK_POSTING
    /** talk 삭제 위해 필요한 포인트*/
    var pointUseDeleteTalk = POINT_FOR_DELETE_TALK
    
    var pointUseReportBadPosting = POINT_FOR_REPORT_BAD_POSTING
    
    /** 마스크 api 주소*/
    var store_api_url = ""
    
    /** 마스크 제고 관련 기능 사용여부*/
    var maskNowEnable = false
    
    var allData:[String:Any] {
        return [
            "maskNowEnable" : maskNowEnable,
            // report
            "waitting_report_distance"  : waitting_report_distance,
            "canViewTalkLogLevel"   : canViewTalkLogLevel,
            
            // game
            "isUsePoker"                : isUsePoker,
            "minBettingPoint"           : minBettingPoint,
            "maxBettingPoint"           : maxBettingPoint,
            "maxJackPotPoint"           : maxJackPotPoint,
            "minJackPotPoint"           : minJackPotPoint,
            "dealarZeroPointBettingRate": dealarZeroPointBettingRate,
            "dealarMaxBettingRate"      : dealarMaxBettingRate,
            "canUsePokerLevel"          : canUsePokerLevel,
            
            // point
            "adRewardPoint"             : adRewardPoint,
            "pointUseRatePosting"       : pointUseRatePosting,
            "pointUseUploadPicture"     : pointUseUploadPicture,
            "pointUseDeleteTalk"        : pointUseDeleteTalk,
            "defaultPoint"              : defaultPoint,
            "levelupReqExpBase"      : levelupReqExpBase,
            "levelupReqExpPlus"      : levelupReqExpPlus,
            "pointForReportStoreStock" : pointForReportStoreStock,
            "pointForReportStoreWait" : pointForReportStoreWait,
            "pointUseReportBadPosting": pointUseReportBadPosting,
            "pointForUnblockPosting":pointForUnblockPosting,
            
            // exp
            "expForReportStoreStock": expForReportStoreStock,
            "expForReportStoreWait" : expForReportStoreWait,
            "expForReportBadPosting" : expForReportBadPosting,
            
            "store_api_url": store_api_url
            
        ]
    }
    
    let keys = [
        [
            "waitting_report_distance",
        ],
        [
            "expForReportStoreStock",
            "expForReportStoreWait",
            "expForReportBadPosting",
            "levelupReqExpBase",
            "levelupReqExpPlus"
        ],
        [
            "adRewardPoint",
            "pointUseRatePosting",
            "pointUseUploadPicture",
            "pointUseDeleteTalk",
            "defaultPoint",
            "pointForReportStoreStock",
            "pointForReportStoreWait",
            "pointUseReportBadPosting",
            "pointForUnblockPosting",
        ],
        [
            "isUsePoker",
            "canUsePokerLevel",
            "minBettingPoint",
            "maxBettingPoint",
            "maxJackPotPoint",
            "minJackPotPoint",
            "dealarZeroPointBettingRate",
            "dealarMaxBettingRate"
        ],
        [
            "canViewTalkLogLevel"
        ],
        [
            "store_api_url",
            "maskNowEnable"
        ]
        
    ]
    
    let sessionTitles = [
        "discance",
        "exp",
        "point",
        "game",
        "permission",
        "etc"
    ]
    
    func setData(key:String, value:String)->Bool {
        let intValue = NSString(string:value).integerValue
        if intValue >= 0 {
            switch key {
            case "pointForUnblockPosting":
                pointForUnblockPosting = intValue
                return true
            case "pointUseReportBadPosting":
                pointUseReportBadPosting = intValue
                return true
            case "pointUseDeleteTalk":
                pointUseDeleteTalk = intValue
                return true
            case "canViewTalkLogLevel":
                canViewTalkLogLevel = intValue
                return true
            case "pointForReportStoreStock":
                pointForReportStoreStock = intValue
                return true
            case "pointForReportStoreWait":
                pointForReportStoreWait = intValue
                return true
            case "expForReportStoreStock":
                expForReportStoreStock = intValue
                return true
            case "expForReportStoreWait":
                expForReportStoreWait = intValue
                return true
            case "expForReportBadPosting":
                expForReportBadPosting = intValue
                return true
            case "levelupReqExpBase":
                levelupReqExpBase = intValue
                return true
            case "levelupReqExpPlus":
                levelupReqExpPlus = intValue
                return true
            case "waitting_report_distance":
                waitting_report_distance = intValue
                return true
            case "minBettingPoint":
                minBettingPoint = intValue
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
            dealarMaxBettingRate = floatValue
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
            break
        }
        
        switch key {
        case "maskNowEnable":
            maskNowEnable = boolValue
            return true
        case "isUsePoker":
            isUsePoker = boolValue
            return true
        default:            
            break
        }
        
        switch key {
        case "store_api_url":
            store_api_url = value
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
        pointForUnblockPosting = data["pointForUnblockPosting"] as? Int ?? POINT_FOR_UNBLOCK_POSTING
        pointUseReportBadPosting = data["pointUseReportBadPosting"] as? Int ?? POINT_FOR_REPORT_BAD_POSTING
        maskNowEnable = data["maskNowEnable"] as? Bool ?? false
        isUsePoker = data["isUsePoker"] as? Bool ?? false
        waitting_report_distance = data["waitting_report_distance"] as? Int ?? WAITING_REPORT_DISTANCE
        minBettingPoint = data["minBettingPoint"] as? Int ?? minBettingPoint
        maxBettingPoint = data["maxBettingPoint"] as? Int ?? maxBettingPoint
        maxJackPotPoint = data["maxJackPotPoint"] as? Int ?? MAX_JACKPOT_POINT
        minJackPotPoint = data["minJackPotPoint"] as? Int ?? MIN_JACKPOT_POINT
        dealarZeroPointBettingRate = data["dealarZeroPointBettingRate"] as? Float ?? D_ZERO_BETTING_RATE
        dealarMaxBettingRate = data["dealarMaxBettingRate"] as? Float ?? D_MAX_BETTING_RATE
        canUsePokerLevel = data["canUsePokerLevel"] as? Int ?? POKER_LEVEL_LIMIG
        adRewardPoint = data["adRewardPoint"] as? Int ?? AD_REWORD
        pointUseUploadPicture = data["pointUseUploadPicture"] as? Int ?? POINT_USE_IMAGE
        pointUseRatePosting = data["pointUseRatePosting"] as? Int ?? POINT_USE_POSTING
        pointUseDeleteTalk = data["pointUseDeleteTalk"] as? Int ?? POINT_FOR_DELETE_TALK
        defaultPoint = data["defaultPoint"] as? Int ?? POINT_DEFAULT
        levelupReqExpPlus = data["levelupReqExpPlus"] as? Int ?? Consts.LEVELUP_REQ_EXP_PLUS
        levelupReqExpBase = data["levelupReqExpBase"] as? Int ?? Consts.LEVELUP_REQ_EXP_BASE
        expForReportStoreWait = data["expForReportStoreWait"] as? Int ?? EXP_FOR_REPORT_WAIT
        expForReportStoreStock = data["expForReportStoreStock"] as? Int ?? EXP_FOR_REPORT_STOCK
        expForReportBadPosting = data["expForReportBadPosting"] as? Int ?? EXP_FOR_REPORT_BAD
        pointForReportStoreStock = data["pointForReportStoreStock"] as? Int ?? POINT_FOR_REPORT_STOCK
        pointForReportStoreWait = data["pointForReportStoreWait"] as? Int ?? POINT_FOR_REPORT_WAIT
        canViewTalkLogLevel = data["canViewTalkLogLevel"] as? Int ?? CAN_VIEW_TALK_LOG_LEVEL
        store_api_url = data["store_api_url"] as? String ?? ""
    }
}


