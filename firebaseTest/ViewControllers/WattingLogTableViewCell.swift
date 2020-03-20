//
//  WaittingLogTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class WaittingLogTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleImageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var profileImageView:UIImageView!
    
    var logid:String? = nil {
        didSet {
            setData()
        }
    }
    
    var log:StoreWaitingModel? {
        if let id = logid {
            return try? Realm().object(ofType: StoreWaitingModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }
    
    fileprivate func setData() {
        titleLabel.text = log?.statusValue?.rawValue.localized
        profileImageView.kf.setImage(with: log?.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        dateLabel.text = log?.regDt.formatedString(format: "HH:MM:ss")
        
        switch self.reuseIdentifier {            
        case "myCell":
            bubbleImageView.image = UIApplication.shared.isDarkMode
                ? #imageLiteral(resourceName: "myBubble_dark") : #imageLiteral(resourceName: "myBubble_light")
        default:
            bubbleImageView.image = UIApplication.shared.isDarkMode
                ? #imageLiteral(resourceName: "bubble_dark") : #imageLiteral(resourceName: "bubble_light")
        }
    }
}
