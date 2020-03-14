//
//  TalkDetailMapTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TalkDetailMapTableViewCell: UITableViewCell {
    @IBOutlet weak var mapView:MKMapView!
    var location : CLLocation? = nil {
        didSet {
            DispatchQueue.main.async {
                if let c = self.location?.coordinate {
                    let ann  = MKPointAnnotation()
                    ann.coordinate = c
                    self.mapView.addAnnotation(ann)
                    self.mapView.centerCoordinate = c
                }
            }
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let camera = MKMapCamera()
        camera.pitch = 45
        camera.altitude = 400
        camera.heading = 45
        self.mapView.camera = camera
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
////        let camera = MKMapCamera()
////        camera.pitch = 45
////        camera.altitude = 500
////        camera.heading = 45
////        mapView.camera = camera
////
//    }
}
