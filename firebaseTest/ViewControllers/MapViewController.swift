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
    var storeCodes:[String] = []
    private var _stores:[StoreModel]? = nil
    private var stores:[StoreModel] {
        if let list = _stores {
            return list
        }
        var list:[StoreModel] = []
        for id in storeCodes {
            if let store = try! Realm().object(ofType: StoreModel.self, forPrimaryKey: id) {
                list.append(store)
            }
        }
        _stores = list
        return list
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if stores.count == 1 {
            title = stores.first?.name
        }
        guard let coordinate = stores.first?.coordinate else {
            return
        }
        
        for store in stores {
            let ann = MKPointAnnotation()
            ann.title = store.name
            ann.coordinate = store.coordinate
            mapView.addAnnotation(ann)
        }
        
        let camera = MKMapCamera()
        camera.centerCoordinate = coordinate
        camera.pitch = 45
        camera.altitude = 1000
        camera.heading = 45
        mapView.camera = camera
    }
    
}
