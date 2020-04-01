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

class ReviewsMapCellTableViewCell: UITableViewCell {
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var button: UIButton!
    let disposeBag = DisposeBag()
    
    var isSetPositionFirst = false
    
    func setDefaultPostion() {
        let camera = MKMapCamera()
        camera.altitude = 1000
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
    }
    
}
