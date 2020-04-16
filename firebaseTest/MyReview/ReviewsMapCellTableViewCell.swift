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
    
    func setDefaultPostion() {
        let camera = MKMapCamera()
        camera.altitude = 500
        camera.pitch = 45
        camera.heading = 45
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
        NotificationCenter.default.addObserver(forName: .locationUpdateNotification, object: nil, queue: nil) { [weak self](notification) in
            if self?.isSetPositionFirst == false {
                self?.setDefaultPostion()
                self?.isSetPositionFirst = true
            }
        }
        NotificationCenter.default.addObserver(forName: .reviews_selectReviewInReviewList, object: nil, queue: nil) {[weak self](notification) in
            if let ids = notification.userInfo?["ids"] as? [String], let isForce = notification.userInfo?["isForce"] as? Bool {
                self?.setAnnotation(reviewIds: ids, isForce: isForce)
            }
        }
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
                let ann = MKPointAnnotation()
                ann.coordinate = location
                ann.title = review?.name
                mapView.addAnnotation(ann)
                mapView.centerCoordinate = location
            }
        }
    }
    
}
