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
    fileprivate var addObserver = false
    func getStores(complete:@escaping(_ count:Int?)->Void) {
        func request(lat:Double,lng:Double,complete:@escaping(_ count:Int?)->Void) {
            let url = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json"
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
            LocationManager.shared.manager.stopUpdatingLocation()
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
    
//    func uploadShopStockLogs(complete:@escaping()->Void) {
//        let time = Date().timeIntervalSince1970 - 60 * 30
//
//        let list = try! Realm().objects(StoreStockLogModel.self)
//            .filter("regDt > %@ && uploaded == %@", Date(timeIntervalSince1970: time), false)
//            .filter("remain_stat == %@",StoreModel.RemainType.plenty.rawValue)
//        var ids:[String] = []
//        for item in list {
//            ids.append(item.id)
//        }
//        func upload(upComplete:@escaping()->Void) {
//            if let id = ids.first {
//                if let model = try! Realm().object(ofType: StoreStockLogModel.self, forPrimaryKey: id) {
//                    if model.store != nil {
//                        #if DEBUG
//                        if let store = model.store {
//                            let msg = "\(store.name) : \(model.remain_stat)"
//                            Toast.makeToast(message:msg)
//                        }
//                        #endif
//                        model.uploadStoreStocks { (isSucess) in
//                            ids.removeFirst()
//                            if ids.count > 0 {
//                                upload(upComplete: upComplete)
//                            } else {
//                                upComplete()
//                            }
//                        }
//                    }
//                }
//            } else {
//                upComplete()
//                return
//            }
//        }
//        upload {
//            complete()
//        }
//    }
        
}
