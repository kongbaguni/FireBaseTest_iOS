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
}
