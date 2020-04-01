//
//  StoresTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/11.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class StoresTableViewCell: UITableViewCell {
    @IBOutlet weak var rankingLabel:UILabel!
    @IBOutlet weak var storeImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var addrLabel:UILabel!
    @IBOutlet weak var distanceLabel:UILabel!
    @IBOutlet weak var stockDtLabel:UILabel!
    
    var storeId:String? = nil {
        didSet {
            setData()
        }
    }
    
    var store:StoreModel? {
        if let id = storeId {
            return try! Realm().object(ofType: StoreModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(forName: .locationUpdateNotification, object: nil, queue: nil) { [weak self](notification) in
            if let location = (notification.object as? [CLLocation])?.first {                
                self?.updateLiveDistance(coordinate: location.coordinate)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }
    
    fileprivate func setData() {
        guard let data = store else {
            return
        }
        switch data.storeType {
        case .pharmacy:
            if #available(iOS 13.0, *) {
                storeImageView.image = #imageLiteral(resourceName: "pharmacy").withTintColor(.autoColor_text_color)
            } else {
                storeImageView.image = #imageLiteral(resourceName: "pharmacy").withRenderingMode(.alwaysTemplate)
            }
        default:
            if #available(iOS 13.0, *) {
                storeImageView.image = #imageLiteral(resourceName: "postoffice").withTintColor(.autoColor_text_color)
            } else {
                storeImageView.image = #imageLiteral(resourceName: "postoffice").withRenderingMode(.alwaysTemplate)
            }
        }
//        distanceLabel.text = "\(Double(Int(data.distance * 100))/100)m"
        if data.distance > 700 {
            distanceLabel.textColor = .red
        } else if data.distance > 400 {
            distanceLabel.textColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        } else {
            distanceLabel.textColor = UIColor(red: 0, green: 0.8, blue: 0.3, alpha: 1)
        }
        
        nameLabel.text = data.name
        addrLabel.text = data.addr
        stockDtLabel.text = "stock at : ".localized + data.stockDtStr
        
    }
    
    func updateLiveDistance(coordinate:CLLocationCoordinate2D){
        if let distance = self.store?.getLiveDistance(coodinate: coordinate) {
            distanceLabel.text = "\(Double(Int(distance * 100))/100)m"
        }
    }
}
