//
//  StoresTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/11.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import CoreLocation

class StoresTableViewCell: UITableViewCell {
    @IBOutlet weak var storeImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var addrLabel:UILabel!
    @IBOutlet weak var distanceLabel:UILabel!
    @IBOutlet weak var stockDtLabel:UILabel!
    
    func setData(data:StoreModel) {        
        switch data.storeType {
        case .pharmacy:
            storeImageView.image = #imageLiteral(resourceName: "pharmacy").withTintColor(.text_color)
        default:
            storeImageView.image = #imageLiteral(resourceName: "postoffice").withTintColor(.text_color)
        }
        distanceLabel.text = nil
        if let last = UserDefaults.standard.lastMyCoordinate {
            let a = CLLocation(latitude: data.coordinate.latitude, longitude: data.coordinate.longitude)
            let b = CLLocation(latitude: last.latitude, longitude: last.longitude)
            let distance = a.distance(from: b)
            
            distanceLabel.text = "\(Int(distance))m"
            if distance > 700 {
                distanceLabel.textColor = .red
            } else if distance > 400 {
                distanceLabel.textColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
            } else {
                distanceLabel.textColor = UIColor(red: 0, green: 1, blue: 0.5, alpha: 1)
            }
        }
        nameLabel.text = data.name
        addrLabel.text = data.addr
        stockDtLabel.text = "stock at:".localized + " " + data.stockDtStr
    }
}
