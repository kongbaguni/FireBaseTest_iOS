//
//  StoresTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/11.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
class StoresTableViewCell: UITableViewCell {
    @IBOutlet weak var storeImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var addrLabel:UILabel!
    @IBOutlet weak var remainStatLabel:UILabel!
    @IBOutlet weak var stockDtLabel:UILabel!
    
    func setData(data:StoreModel) {        
        switch data.storeType {
        case .pharmacy:
            storeImageView.image = #imageLiteral(resourceName: "pharmacy").withTintColor(.text_color)
        default:
            storeImageView.image = #imageLiteral(resourceName: "postoffice").withTintColor(.text_color)
        }
        
        nameLabel.text = data.name
        addrLabel.text = data.addr
        remainStatLabel.text = data.remain_stat.localized
        stockDtLabel.text = "stock at:".localized + " " + data.stockDtStr
    }
}
