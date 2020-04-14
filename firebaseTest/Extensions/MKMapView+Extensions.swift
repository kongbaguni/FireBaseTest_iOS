//
//  MKMapView+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import MapKit
extension MKMapView {
    func clearMemory() {
        switch (self.mapType) {
           case MKMapType.hybrid:
               mapType = MKMapType.standard
           case MKMapType.standard:
               mapType = MKMapType.hybrid
           default:
               break
           }
           showsUserLocation = false
           delegate = nil
           removeFromSuperview()
    }
}
