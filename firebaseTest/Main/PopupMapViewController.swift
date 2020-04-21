//
//  PopupMapViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/27.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift

class PopupMapViewController: UIViewController {
    static func viewController(coordinate:CLLocationCoordinate2D?, title:String?, annTitle:String?)->PopupMapViewController {
        let vc:PopupMapViewController
        if #available(iOS 13.0, *) {
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "popupMapView") as! PopupMapViewController
        } else {
             vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupMapView") as! PopupMapViewController
        }
        vc.coordinate = coordinate
        vc.title = title
        vc.annTitle = annTitle
        return vc
    }
    
    @IBOutlet weak var closeBtn:UIButton!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate var coordinate:CLLocationCoordinate2D? = nil
    fileprivate var annTitle:String? = nil
    fileprivate let disposebag = DisposeBag()
    
    var altitude:CLLocationDistance = 1500
    
    deinit {
        mapView.clearMemory()
        debugPrint("deinit PopupMapViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = title
        let camera = MKMapCamera()
        camera.altitude = altitude
        camera.pitch = 45
        camera.heading = 45
        mapView.camera = camera
        if let value = coordinate {
            let ann = MKPointAnnotation()
            ann.coordinate = value
            ann.title = annTitle
            mapView.addAnnotation(ann)
            mapView.centerCoordinate = value
        }
        contentView.setBorder(borderColor: .autoColor_text_color, borderWidth: 0.5, radius: 20, masksToBounds: true)

        closeBtn.setImage(.closeBtnImage_normal, for: .normal)
        closeBtn.setImage(.closeBtnImage_highlighted, for: .highlighted)
        closeBtn.rx.tap.bind { (_) in
            self.mapView.clearMemory()
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposebag)
 
        closeBtn.tintColor = .autoColor_text_color
    }
}
