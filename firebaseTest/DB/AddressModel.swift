//
//  AddressModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/20.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import FirebaseStorage

class AddressModel: Object {
    @objc dynamic var place_id:String = ""
    @objc dynamic var formatted_address:String = ""
    @objc dynamic var viewport_southwest_lng:Double = 0
    @objc dynamic var viewport_southwest_lat:Double = 0
    @objc dynamic var viewport_northeast_lng:Double = 0
    @objc dynamic var viewport_northeast_lat:Double = 0
    @objc dynamic var location_lng:Double = 0
    @objc dynamic var location_lat:Double = 0
    @objc dynamic var postal_code:String = ""
    
    override static func primaryKey() -> String? {
        return "place_id"
    }
}

extension AddressModel {
    static func makeData(place_id:String, formatted_address:String, viewport_southwest:CLLocationCoordinate2D, viewport_northeast:CLLocationCoordinate2D, location:CLLocationCoordinate2D, postal_code:String)->[String:Any] {
        return [
            "place_id":place_id,
            "formatted_address":formatted_address,
            "viewport_southwest_lng":viewport_southwest.longitude,
            "viewport_southwest_lat":viewport_southwest.latitude,
            "viewport_northeast_lng":viewport_northeast.longitude,
            "viewport_northeast_lat":viewport_northeast.latitude,
            "location_lng":location.longitude,
            "location_lat":location.latitude,
            "postal_code":postal_code
        ]
    }
    
    static func create(data:[String:Any], complete:@escaping(_ placeId:String?)->Void) {
        guard let place_id = data["place_id"] as? String else {
            complete(nil)
            return
        }
        FS.store.collection(FSCollectionName.ADDRESS).document(place_id).setData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(AddressModel.self, value: data, update: .all)
                try! realm.commitWrite()
                complete(place_id)
            } else {
                complete(nil)
            }
        }
    }
    
    var location:CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location_lat, longitude: location_lng)
    }
        
    var viewPorts:[CLLocationCoordinate2D] {
        return [
            CLLocationCoordinate2D(latitude: viewport_northeast_lat, longitude: viewport_northeast_lng),
            CLLocationCoordinate2D(latitude: viewport_northeast_lat, longitude: viewport_southwest_lng),
            CLLocationCoordinate2D(latitude: viewport_southwest_lat, longitude: viewport_southwest_lng),
            CLLocationCoordinate2D(latitude: viewport_southwest_lat, longitude: viewport_northeast_lng)
        ]
    }
    
    var viewPortDistance:CLLocationDistance {
        let a = CLLocation(latitude: viewport_northeast_lat, longitude: viewport_northeast_lng)
        let b = CLLocation(latitude: viewport_southwest_lat, longitude: viewport_southwest_lng)
        return a.distance(from: b)
    }
}
