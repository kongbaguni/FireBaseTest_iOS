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
}
