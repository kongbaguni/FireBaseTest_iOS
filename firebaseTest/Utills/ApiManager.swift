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

class ApiManager {
    static let shard = ApiManager()
    func getStores(complete:@escaping(_ count:Int?)->Void) {
        func request(lat:Double,lng:Double,complete:@escaping(_ count:Int?)->Void) {
            let url = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json"
            print( UserInfo.info?.distanceForSearch )
            let distanc = UserInfo.info?.distanceForSearch ?? Consts.DISTANCE_STORE_SEARCH
            AF.request(url, method: .get, parameters: [
                "lat" : lat,
                "lng" : lng,
                "m" : distanc
            ]).response { (response) in
                if let data = response.data {
                    print("-------------------")
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                        if let array = json["stores"] as? [[String:Any]] {
                            var stores:[Object] = []
                            for storeInfo in array {
                                let store = StoreModel()
                                store.setJson(data: storeInfo)
                                stores.append(store)
                                store.searchDisance = UserInfo.info?.distanceForSearch ?? Consts.DISTANCE_STORE_SEARCH
                                if StoreStockLogModel.getLastStat(shopcode: store.code) != store.remain_stat {
                                    let log = StoreStockLogModel()
                                    log.code = store.code
                                    log.remain_stat = store.remain_stat
                                    stores.append(log)
                                }
                            }
                            
                            let realm = try! Realm()
                            realm.beginWrite()
                            realm.delete(realm.objects(StoreModel.self))
                            realm.add(stores,update: .all)
                            try! realm.commitWrite()
                            complete(stores.count)
                            print("\(stores.count)")
                            return
                        }
                    }
                    print("-------------------")
                }
                complete(nil)
            }
        }
                
        LocationManager.shared.requestAuth { status in
            switch status {
            case .denied:                
                complete(nil)
            case .none:
                complete(nil)

            default:
                LocationManager.shared.manager.startUpdatingLocation()
                NotificationCenter.default.addObserver(forName: .locationUpdateNotification, object: nil, queue: nil) {(notification) in
                    LocationManager.shared.manager.stopUpdatingLocation()
                    if let locations = notification.object as? [CLLocation] {
                        if let location = locations.first {
                            UserDefaults.standard.lastMyCoordinate = location.coordinate
                            request(lat: location.coordinate.latitude, lng: location.coordinate.longitude) { (count) in
                                complete(count)
                            }
                        }

                        return
                    }
                    complete(nil)
                }
            }
        }
    }
}
