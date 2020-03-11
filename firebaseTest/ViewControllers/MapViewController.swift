//
//  MapViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/11.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import RealmSwift

class MapViewController: UIViewController {
    @IBOutlet weak var mapView:MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.requestAuth {
            print("!!!")
            LocationManager.shared.manager.startUpdatingLocation()
        }
        title = "mask now".localized
        NotificationCenter.default.addObserver(forName: .locationUpdateNotification, object: nil, queue: .main) { [weak self] (notification) in
            print(notification)
            if let locations = notification.object as? [CLLocation] {
                for location in locations {
                    if self?.requestCount == 0 {
                        self?.requestStoreInfo(coordinate: location.coordinate)
                    }
                }
                
            }
        }
        
    }
    
    var requestCount = 0
    func requestStoreInfo(coordinate:CLLocationCoordinate2D)  {
        requestCount += 1
        let url = "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1/storesByGeo/json"
        Alamofire
            .request(url, method: .get, parameters: [
                "lat" : coordinate.latitude,
                "lang" : coordinate.longitude,
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
                        }
                    }
                    
                    print("-------------------")
                }
        }
    }
}
