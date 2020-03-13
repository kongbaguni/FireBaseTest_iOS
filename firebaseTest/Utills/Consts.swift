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
    /** 글 쓰기 위한 포인트 소모량*/
    static let POINT_FOR_WRITE:Int = 100
    /** 광고 시청 1회당 받는 포인트*/
    static var POINT_BY_AD:Int {
        let level = UserInfo.info?.level ?? 0
        return 100 + (level * 10)
    }
    /** 레벨업에 필요한 경험치*/
    static var LEVELUP_REQ_EXP:Int {
        let level = UserInfo.info?.level ?? 0
        return 10000 + (level * 100)
    }
    
    static let SEARCH_DISTANCE_LIST:[Int] = [500,1000,2000]
}
