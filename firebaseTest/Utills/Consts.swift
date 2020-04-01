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
    static let DISTANCE_STORE_SEARCH:Int = 500

    static var MAX_GAME_COUNT:Int {
        let level = UserInfo.info?.level ?? 0
        return 3 + (level/10)
    }
    
    /** 레벨업에 필요한 경험치 기본값*/
    static var LEVELUP_REQ_EXP_BASE:Int = 1000
    
    /** 렙벨업에 필요한 경험치 1레벨당 증가하는 계수*/
    static var LEVELUP_REQ_EXP_PLUS:Int = 100
    
    /** 최대 베팅 포인트 제한*/
    static var BETTING_LIMIT = 1000
    
    /** 검색 거리 목록*/
    static var SEARCH_DISTANCE_LIST:[Int] {
        if Consts.isAdmin {
            return [500,1000,2000,3000,4000,5000,6000]
        }
        if let userInfo = UserInfo.info {
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
    
    static let REALM_VERSION:UInt64 = 15
    
    static var isAdmin:Bool {
        return UserInfo.info?.id == "kongbaguni@gmail.com"
    }
        
}

/** 파이어베이스 스토리지 아이디*/
struct FSCollectionName {
    #if DEBUG
    static let STORE_STOCK = "storeStock_TEST"
    static let JACKPOT = "jackPot_TEST"
    static let ADMIN = "admin_TEST"
    static let TALKS = "talks_TEST"
    static let USERS = "users_TEST"
    static let STORAGE_PROFILE_IMAGE = "profileImages_TEST"
    static let STORAGE_TLAK_IMAGE = "tlak_images_TEST"
    static let STORAGE_REVIEW_IMAGE = "review_images_TEST"
    static let NOTICE = "notice_TEST"
    static let REVIEW = "review_TEST"
    #else
    static let STORE_STOCK = "storeStock"
    static let JACKPOT = "jackPot"
    static let ADMIN = "admin"
    static let TALKS = "talks"
    static let USERS = "users"
    static let STORAGE_PROFILE_IMAGE = "profileImages"
    static let STORAGE_TLAK_IMAGE = "tlak_images"
    static let STORAGE_REVIEW_IMAGE = "review_images"
    static let NOTICE = "notice"
    static let REVIEW = "review"
    #endif
}
