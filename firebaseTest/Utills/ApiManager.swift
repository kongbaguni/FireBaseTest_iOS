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

class ApiManager {
    func getStores(lat:Double,lng:Double,complete:@escaping(_ count:Int?)->Void) {
        let url = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json"
        Alamofire
            .request(url, method: .get, parameters: [
                "lat" : lat,
                "lng" : lng,
                "m" : 1000
            ])
            .response { (response) in
                if let data = response.data {
                    print("-------------------")
                    print(data)
                    print("-------------------")
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                        if let array = json["stores"] as? [[String:Any]] {
                            var stores:[StoreModel] = []
                            for storeInfo in array {
                                let store = StoreModel()
                                store.setJson(data: storeInfo)
                                stores.append(store)
                            }
                            
                            let realm = try! Realm()
                            realm.beginWrite()
                            realm.add(stores,update: .all)
                            try! realm.commitWrite()
                            complete(stores.count)
                            return
                        }
                    }
                    print("-------------------")
                }
                complete(nil)
        }
    }
}
