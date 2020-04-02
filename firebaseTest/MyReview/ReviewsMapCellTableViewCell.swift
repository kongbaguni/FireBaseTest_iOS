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
    @IBOutlet weak var button: UIButton!
    let disposeBag = DisposeBag()
    
    var isSetPositionFirst = false
    
    func setDefaultPostion() {
        let camera = MKMapCamera()
        camera.altitude = 500
        camera.pitch = 45
        camera.heading = 45
        mapView.camera = camera
        if let value = UserDefaults.standard.lastMyCoordinate {
            mapView.centerCoordinate = value
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        
        button.rx.tap.bind { (_) in
            self.setDefaultPostion()
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(forName: .locationUpdateNotification, object: nil, queue: nil) { [weak self](notification) in
            if self?.isSetPositionFirst == false {
                self?.setDefaultPostion()
                self?.isSetPositionFirst = true
            }
        }
        NotificationCenter.default.addObserver(forName: .reviews_selectReviewInReviewList, object: nil, queue: nil) {[weak self](notification) in
            if let ids = notification.userInfo?["ids"] as? [String], let isForce = notification.userInfo?["isForce"] as? Bool {
                if let anns = self?.mapView.annotations {
                    if anns.count > 0 && isForce == false {
                        return
                    }
                    self?.mapView.removeAnnotations(anns)
                }
                for id in ids {
                let review = try! Realm().object(ofType: ReviewModel.self, forPrimaryKey: id)
                    if let location = review?.location {
                        let ann = MKPointAnnotation()
                        ann.coordinate = location
                        ann.title = review?.name
                        self?.mapView.addAnnotation(ann)
                        self?.mapView.centerCoordinate = location
                    }
                }
            }
        }
    }
    
}
