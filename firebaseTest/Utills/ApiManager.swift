//
//  ApiManager.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/11.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import CoreLocation
import SwiftyJSON

class ApiManager {
    static let shard = ApiManager()
    fileprivate var addObserver = false
    func getStores(complete:@escaping(_ count:Int?)->Void) {
        func request(lat:Double,lng:Double,complete:@escaping(_ count:Int?)->Void) {
            let url = AdminOptions.shared.store_api_url 
            let distanc = UserInfo.info?.distanceForSearch ?? Consts.DISTANCE_STORE_SEARCH
            AF.request(url, method: .get, parameters: [
                "lat" : lat,
                "lng" : lng,
                "m" : distanc
            ]).response { (response) in
                if let data = response.data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                        if let array = json["stores"] as? [[String:Any]] {
                            var stores:[Object] = []
                            for storeInfo in array {
                                let store = StoreModel()
                                store.setJson(data: storeInfo)
                                stores.append(store)
                                store.searchDisance = UserInfo.info?.distanceForSearch ?? Consts.DISTANCE_STORE_SEARCH
                            }
                            
                            let realm = try! Realm()
                            realm.beginWrite()
                            realm.delete(realm.objects(StoreModel.self))
                            realm.add(stores,update: .all)
                            try! realm.commitWrite()
                            complete(stores.count)
                            return
                        }
                    }
                }
                complete(nil)
            }
        }
                
        LocationManager.shared.requestAuth(complete: { (status) in
            switch status {
            case .denied:
                complete(nil)
            case .none:
                complete(nil)
            default:                
                LocationManager.shared.manager.startUpdatingLocation()
            }

        }) { (locations) in
            if let location = locations.first {
                UserDefaults.standard.lastMyCoordinate = location.coordinate
                request(lat: location.coordinate.latitude, lng: location.coordinate.longitude) { (count) in
                    complete(count)
                }
                return
            }
            complete(nil)
        }
        
    }

    
    func getAddresFromGeo(coordinate:CLLocationCoordinate2D?, getAddress:@escaping(_ place_id:[String]?)->Void) {
        guard let coordinate = coordinate else {
            getAddress(nil)
            return
        }
        
        let lang = Locale.preferredLanguages.first ?? "ko"
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json"
        AF
            .request(url, method: .get, parameters:[
            "latlng":"\(coordinate.latitude),\(coordinate.longitude)",
            "language":lang,
            "key":"AIzaSyDdTwlHFGHLz1PYLjQI_Llp8EbCO5csFx8"
        ])
            .response { (data) in
                guard let data = data.data else {
                    getAddress(nil)
                    return
                }
                
                guard let json = try? JSON(data: data) else {
                    getAddress(nil)
                    return
                }
                print(json)
                var ids:[String] = []
                var address:[[String:Any]] = []
                let results = json["results"].arrayValue
                
                for result in results {
                    guard let formatted_address = result["formatted_address"].string,
                        let place_id = result["place_id"].string,
                        let lnlat = result["geometry"]["viewport"]["northeast"]["lat"].double,
                        let lnlng = result["geometry"]["viewport"]["northeast"]["lng"].double,
                        let lslat = result["geometry"]["viewport"]["southwest"]["lat"].double,
                        let lslng = result["geometry"]["viewport"]["southwest"]["lng"].double,
                        let lng = result["geometry"]["location"]["lng"].double,
                        let lat = result["geometry"]["location"]["lat"].double
                        else {
                        continue
                    }
                    var postal_code = ""
                    for component in result["address_components"].arrayValue {
                        for type in component["types"].arrayValue {
                            if type.stringValue == "postal_code" {
                                postal_code = component["long_name"].stringValue
                            }
                        }
                    }
                    let data = AddressModel.makeData(
                        place_id: place_id,
                        formatted_address: formatted_address,
                        viewport_southwest: CLLocationCoordinate2D(latitude: lslat, longitude: lslng),
                        viewport_northeast: CLLocationCoordinate2D(latitude: lnlat, longitude: lnlng),
                        location: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                        postal_code: postal_code)
                    
                    ids.append(place_id)
                    address.append(data)
                }
                
                let realm = try! Realm()
                if address.count > 0 {
                    realm.beginWrite()
                    for data in address {
                        realm.create(AddressModel.self, value: data, update: .all)
                    }
                    try! realm.commitWrite()
                }
                
                if address.count == 0 {
                    getAddress(nil)
                } else {
                    getAddress(ids)
                }
        }
    }
        
}
