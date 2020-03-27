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
    static func viewController(coordinate:CLLocationCoordinate2D?, title:String?)->PopupMapViewController {
        let vc:PopupMapViewController
        if #available(iOS 13.0, *) {
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "popupMapView") as! PopupMapViewController
        } else {
             vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupMapView") as! PopupMapViewController
        }
        vc.coordinate = coordinate
        vc.title = title
        return vc
    }
    
    @IBOutlet weak var closeBtn:UIButton!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var coordinate:CLLocationCoordinate2D? = nil
    
    fileprivate let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = title
        let camera = MKMapCamera()
        camera.altitude = 1500
        camera.pitch = 45
        camera.heading = 45
        mapView.camera = camera
        if let value = coordinate {
            let ann = MKPointAnnotation()
            ann.coordinate = value
            ann.title = title
            mapView.addAnnotation(ann)
            mapView.centerCoordinate = value
        }
        contentView.setBorder(borderColor: .autoColor_text_color, borderWidth: 0.5, radius: 20, masksToBounds: true)

        closeBtn.setImage(.closeBtnImage_normal, for: .normal)
        closeBtn.setImage(.closeBtnImage_highlighted, for: .highlighted)
        closeBtn.rx.tap.bind { (_) in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposebag)
        
    }
}
