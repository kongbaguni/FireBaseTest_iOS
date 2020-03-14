//
//  Consts.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
struct Consts {
    /** 이야기 표시 기간*/
    static let LIMIT_TALK_TIME_INTERVAL:TimeInterval = 86400
    
    /** 상점 검색 범의 (미터 단위)*/
    static let DISTANCE_STORE_SEARCH:Int = 500

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
    
    static let REALM_VERSION:UInt64 = 4
}
