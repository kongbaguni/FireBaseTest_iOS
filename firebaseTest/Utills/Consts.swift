//
//  Consts.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
struct Consts {
    /** 상점 검색 범의 (미터 단위)*/
    static var DISTANCE_STORE_SEARCH:Int = 500
    
    #if DEBUG
    /** 대기열 보고 위한 거리제한*/
    static let WAITING_REPORT_DISTANCE:Int = 500
    #else
    /** 대기열 보고 위한 거리제한*/
    static let WAITING_REPORT_DISTANCE:Int = 50
    #endif
    
    static var MAX_GAME_COUNT:Int {
        let level = UserInfo.info?.level ?? 0
        return 3 + (level/10)
    }
    /** 레벨업에 필요한 경험치*/
    static var LEVELUP_REQ_EXP:Int {
        let level = UserInfo.info?.level ?? 0
        return 10000 + (level * 100)
    }
    
    /** 광고 시청 1회당 받는 포인트*/
    static var POINT_BY_AD:Int {
        let level = UserInfo.info?.level ?? 0
        return 100 + (level * 10)
    }
    /** 최대 베팅 포인트 제한*/
    static var BETTING_LIMIT = 1000
    
    /** 검색 거리 목록*/
    static var SEARCH_DISTANCE_LIST:[Int] {
        if let userInfo = UserInfo.info {
            if userInfo.email == "kongbaguni@gmail.com" {
                return [500,1000,2000,3000,4000,5000,6000]
            }
            if userInfo.level < 10 {
                return [500,1000]
            }
            if userInfo.level < 50 {
                return [500,1000,2000]
            }
            if userInfo.level < 100 {
                return [500,1000,2000,3000]
            }
            if userInfo.level < 500 {
                return [500,1000,2000,3000,4000]
            }
            if userInfo.level < 1000 {
                return [500,1000,2000,3000,4000,5000]
            }
            else {
                return [500,1000,2000,3000,4000,5000,6000]
            }
        }
        return [500]
    }
    /** 구글 광고 아이디*/
    static let GADID = "ca-app-pub-7714069006629518/9754456852"
    
    static let REALM_VERSION:UInt64 = 0

}
