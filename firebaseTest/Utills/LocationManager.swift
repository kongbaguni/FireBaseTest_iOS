//
//  LocationManager.swift
//  test
//
//  Created by Changyul Seo on 2019/11/05.
//  Copyright © 2019 서창열. All rights reserved.
//

import Foundation
import CoreLocation
extension Notification.Name {
    static let locationUpdateNotification = Notification.Name(rawValue: "locationUpdateNotification")
}

class LocationManager: NSObject {
    static let shared = LocationManager()
    var authStatus:CLAuthorizationStatus? = nil
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    private var complete:((_ status:CLAuthorizationStatus?)->Void)? = nil
    private var getLocation:((_ locations:[CLLocation])->Void)? = nil
    
    func requestAuth(complete:@escaping(_ status:CLAuthorizationStatus?)->Void, getLocation:@escaping(_ locations: [CLLocation])->Void) {
        self.getLocation = getLocation
        if let status = authStatus {
            complete(status)
        } else {
            manager.requestWhenInUseAuthorization()
            self.complete = complete
        }
    }
    
    var status:Permission.Status {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return .authorized
        case .denied:
            return .denined
        case .notDetermined:
            return .notDetermined
        default:
            return .restricted
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authStatus = status
        complete?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        self.getLocation?(locations)
        NotificationCenter.default.post(Notification(name: .locationUpdateNotification, object: locations, userInfo: nil))
    }
    
}
