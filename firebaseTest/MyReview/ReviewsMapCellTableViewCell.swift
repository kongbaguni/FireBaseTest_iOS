//
//  ReviewsMapCellTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/31.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import RealmSwift

class ReviewsMapCellTableViewCell: UITableViewCell {
    @IBOutlet weak var mapView:MKMapView!
    
    var isSetPositionFirst = false
    
    var altitude:CLLocationDistance = 500 {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.setDefaultPostion(altitude: self?.altitude)
            }
        }
    }
    
    func setDefaultPostion(altitude :CLLocationDistance? = nil) {
        let camera = MKMapCamera()
        camera.altitude = altitude ?? self.altitude
        camera.pitch = 45
        camera.heading = 45
        mapView.mapType = UserInfo.info?.mapTypeValue.mapTypeValue ?? MKMapType.standard
        mapView?.camera = camera
        if let value = UserDefaults.standard.lastMyCoordinate {
            mapView?.centerCoordinate = value
        }
    }

    deinit {
        mapView?.clearMemory()
        debugPrint("deinit ReviewsMapCellTableViewCell")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if mapView?.superview == nil && mapView != nil {
            self.addSubview(mapView)
        }
                
    }
    
    fileprivate var isAddObserver = false
    func addObserver() {
        if isAddObserver {
            return
        }
//        NotificationCenter.default.addObserver(forName: .locationUpdateNotification, object: nil, queue: nil) { [weak self](notification) in
//            if self?.isSetPositionFirst == false {
//                self?.setDefaultPostion()
//                self?.isSetPositionFirst = true
//            }
//        }
//        NotificationCenter.default.addObserver(forName: .reviews_selectReviewInReviewList, object: nil, queue: nil) {[weak self](notification) in
//            if let ids = notification.userInfo?["ids"] as? [String], let isForce = notification.userInfo?["isForce"] as? Bool {
//                self?.setAnnotation(reviewIds: ids, isForce: isForce)
//            }
//        }
        isAddObserver = true
    }
    
    func setAnnotation(reviewIds:[String], isForce:Bool) {
        guard let mapView = self.mapView else {
            return
        }
        let anns = mapView.annotations
        if anns.count > 0 && isForce == false {
            return
        }
        mapView.removeAnnotations(anns)
        
        for id in reviewIds {
        let review = try! Realm().object(ofType: ReviewModel.self, forPrimaryKey: id)
            if let location = review?.location {
                func addPoint(coordinate:CLLocationCoordinate2D, title:String?) {
                    let ann = MKPointAnnotation()
                    ann.title = title
                    ann.coordinate = coordinate
                    mapView.addAnnotation(ann)
                }
                
                let ann = MKPointAnnotation()
                if let place = review?.place {
                    addPoint(coordinate: place.location, title: "\(place.formatted_address) \(review?.place_detail ?? "")" )
                    mapView.centerCoordinate = place.location
                    altitude = place.viewPortDistance
                } else {
                    addPoint(coordinate: location, title: review?.name)
                    mapView.centerCoordinate = location
                }
                mapView.addAnnotation(ann)
                
            }
        }
    }
    
}
