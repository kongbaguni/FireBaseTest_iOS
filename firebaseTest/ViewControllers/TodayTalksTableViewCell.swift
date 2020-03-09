//
//  TodayTalksTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
class TodayTalksTableViewCell: UITableViewCell {
    @IBOutlet weak var porfileImageView:UIImageView!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var talkLabel:UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    func setData(data:TalkModel) {
        talkLabel.text = "\(data.text) + \(data.likes.count)"
        nameLabel.text = data.creator?.name ?? "unknown people".localized
        self.porfileImageView.kf.setImage(with: data.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))

        
        if data.regTimeIntervalSince1970 != data.modifiedTimeIntervalSince1970 {
            dateLabel.textColor = .red
            dateLabel.text = "\(data.regDtStr) 수정 : \(data.modifiedDtStr!)"
        } else {
            dateLabel.textColor = .darkText
            dateLabel.text = data.regDtStr
        }
    }
}
