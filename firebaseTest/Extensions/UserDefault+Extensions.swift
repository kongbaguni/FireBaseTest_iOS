//
//  UserDefault+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

extension UserDefaults {
    // 나의 마지막 위치정보 저장
    var lastMyCoordinate: CLLocationCoordinate2D? {
        set {
            if let value = newValue {
                set(value.latitude, forKey: "last_latitude")
                set(value.longitude, forKey: "last_longitude")
            } else {
                set(nil, forKey: "last_latitude")
                set(nil, forKey: "last_longitude")
            }
        }
        get {
            let last_latitude = double(forKey: "last_latitude")
            let last_longitude = double(forKey: "last_longitude")
            if last_longitude > 0 && last_longitude > 0 {
                return CLLocationCoordinate2D(latitude: last_latitude, longitude: last_longitude)
            }
            return nil
        }
    }
    
    /** 게임 톡 감추기*/
    var isHideGameTalk:Bool {
        set {
            set(newValue, forKey: "hideGameTalk")
        }
        get {
            if AdminOptions.shared.canPlayPoker == false {
                return true
            } else {
                return bool(forKey: "hideGameTalk")
            }
        }
    }
    
    /** 근처의 이야기만 보기*/
    var isShowNearTalk:Bool {
        set {
            set(newValue, forKey: "showNearTalk")
        }
        get {
            bool(forKey: "showNearTalk")
        }
    }
    
    var lastBettingPoint:Int {
        set {
            set(newValue, forKey: "lastBettingPoint")
        }
        get {
            integer(forKey: "lastBettingPoint")
        }
    }
    
    var lastTypeOfRanking:UserInfo.RankingType? {
        set {
            set(newValue?.rawValue, forKey:"lastRankingTypeOfRanking")
        }
        get {
            if let str = string(forKey: "lastRankingTypeOfRanking") {
                return UserInfo.RankingType(rawValue: str)
            }
            return nil
        }
    }
    
    var showModifiedOnly:Bool {
        set {
            set(newValue, forKey: "showModifiedOnly")
        }
        get {
            bool(forKey: "showModifiedOnly")
        }
    }
    
    var lastInAppPurchaseExpireDate:Date? {
        set {
            if let value = newValue {
                let time = value.timeIntervalSince1970
                let d = Double(time)
                set(d, forKey: "lastInAppPurchaseExpireDate")
            }
            else {
                removeObject(forKey: "lastInAppPurchaseExpireDate")
            }
        }
        get {
            let d = double(forKey: "lastInAppPurchaseExpireDate")
            if d == 0 {
                return nil
            }
            let interval = TimeInterval(d)
            return Date(timeIntervalSince1970: interval)
        }
    }
}
