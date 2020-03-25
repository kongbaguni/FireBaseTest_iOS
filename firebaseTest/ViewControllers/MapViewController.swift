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

class MyPointAnnotation : MKPointAnnotation {
    var storeCode:String? = nil
    var store:StoreModel? {
        if let code = storeCode {
            return try! Realm().object(ofType: StoreModel.self, forPrimaryKey: code)
        }
        return nil
    }
}

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
        mapView.delegate = self
        mapView.mapType = UserInfo.info?.mapTypeValue.mapTypeValue ?? MKMapType.standard
        if stores.count == 1 {
            title = stores.first?.name
        } else {
            title = "Store location".localized
        }
        guard let coordinate = stores.first?.coordinate else {
            return
        }
        
        for store in stores {
            let ann = MyPointAnnotation()
            ann.title = store.name
            ann.storeCode = store.code
            ann.coordinate = store.coordinate
            mapView.addAnnotation(ann)
        }
        
        let camera = MKMapCamera()
        if stores.count == 1 {
            camera.centerCoordinate = coordinate
        } else {
            camera.centerCoordinate = UserDefaults.standard.lastMyCoordinate ?? coordinate
        }
        camera.pitch = 45
        camera.altitude = stores.count == 1 ? 500 : 1000
        camera.heading = 45
        mapView.camera = camera
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showStoreStockLogs":
            if let vc = segue.destination as? StoreStockLogTableViewController {
                vc.code = sender as? String
            }
        default:
            break
        }
    }
        
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKMarkerAnnotationView        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
        }

        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.annotation = annotation
            annotationView?.markerTintColor = annotation.store?.remainType?.colorValue
            annotationView?.glyphText = annotation.title
        } else {
            return nil
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if UserInfo.info != nil {
            if let code = (view.annotation as? MyPointAnnotation)?.storeCode {
                performSegue(withIdentifier: "showStoreStockLogs", sender: code)
            }
        }
    }
}
