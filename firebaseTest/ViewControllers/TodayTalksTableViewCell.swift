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
        let text = NSMutableAttributedString(string: "")
        if data.likes.count > 0 {
            if data.modifiedTimeIntervalSince1970 != data.regTimeIntervalSince1970 {
                text.append(NSAttributedString(string: "edit : \(data.modifiedDtStr ?? "") \n", attributes: [
                    .font               : UIFont.systemFont(ofSize: 10)
                ]))
            }
            text.append(NSAttributedString(string: data.text))
            text.append(NSAttributedString(string: "\n"))
            text.append(NSAttributedString(string: "like : ".localized, attributes: [
                .font               : UIFont.systemFont(ofSize: 10)
            ]))
            text.append(NSAttributedString(string: "\(data.likes.count)", attributes: [
                .font               : UIFont.boldSystemFont(ofSize: 10),
                .foregroundColor    : UIColor.bold_text_color
            ]))
        }
        
        talkLabel.attributedText = text
        nameLabel.text = data.creator?.name ?? "unknown people".localized
        self.porfileImageView.kf.setImage(with: data.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        dateLabel.text = data.regDtStr
        dateLabel.textColor = .text_color
    }
}
