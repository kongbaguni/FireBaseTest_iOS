//
//  StoreStockLogTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class StoreStockLogTableViewCell : UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var reporterLabel:UILabel!
    @IBOutlet weak var statusLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    
    var stockId:String? = nil {
        didSet {
            setData()
        }
    }
    
    var stock:StoreStockLogModel? {
        if let id = stockId {
            return try! Realm().object(ofType: StoreStockLogModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }
    
    fileprivate func setData() {
        guard let stock = self.stock else {
            return
        }
        profileImageView.kf.setImage(with: stock.uploader?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        reporterLabel.text = "reporter".localized
        statusLabel.text = stock.remain_stat.localized
        statusLabel.textColor = StoreModel.RemainType(rawValue: stock.remain_stat)?.colorValue
        dateLabel.text = stock.regDt.formatedString(format:"MM/dd HH:mm:ss")
    }
}
