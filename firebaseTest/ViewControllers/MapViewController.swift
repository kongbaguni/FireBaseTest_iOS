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
    var storeCode:String? = nil
    var store:StoreModel? {
        if let code = storeCode {
            return try! Realm().object(ofType: StoreModel.self, forPrimaryKey: code)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = store?.name
        if let store = store {
            let ann = MKPointAnnotation()
            ann.title = store.name
            ann.coordinate = store.coordinate
            mapView.addAnnotation(ann)
        }
    }
    
}
