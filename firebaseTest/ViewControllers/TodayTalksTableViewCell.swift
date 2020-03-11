//
//  TodayTalksTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
fileprivate let textStyle0:[NSAttributedString.Key:Any] = [
    .font               : UIFont.systemFont(ofSize: 18),
    .foregroundColor    : UIColor.text_color
]

fileprivate let textStyle1:[NSAttributedString.Key:Any] = [
    .font               : UIFont.systemFont(ofSize: 10),
    .foregroundColor    : UIColor.text_color
]

fileprivate let textStyle2:[NSAttributedString.Key:Any] = [
    .font               : UIFont.boldSystemFont(ofSize: 10),
    .foregroundColor    : UIColor.bold_text_color
]

class TodayTalksTableViewCell: UITableViewCell {
    @IBOutlet weak var porfileImageView:UIImageView!
    @IBOutlet weak var talkTextView:UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    func setData(data:TalkModel) {
        talkTextView.textColor = .text_color
        let text = NSMutableAttributedString()
        
        if let txt = data.editList.last?.text {
            text.append(NSAttributedString(string: txt, attributes: textStyle0))
        } else {
            text.append(NSAttributedString(string: data.text, attributes: textStyle0))
        }

        if data.likes.count > 0 {
            text.append(NSAttributedString(string: "\n\n"))
            text.append(NSAttributedString(string: "like : ".localized, attributes: textStyle2))
            text.append(NSAttributedString(string: "\(data.likes.count)", attributes: textStyle1))
        }
        text.append(NSAttributedString(string: "\n\n"))
        text.append(NSAttributedString(string: "reg : ".localized, attributes: textStyle2))
        text.append(NSAttributedString(string: "\(data.regDt.relativeTimeStringValue)", attributes: textStyle1))

        if let editDt = data.editList.last?.regDt.relativeTimeStringValue {
            text.append(NSAttributedString(string: "\n"))
            text.append(NSAttributedString(string: "edit : ".localized, attributes: textStyle2))
            text.append(NSAttributedString(string: "\(editDt)", attributes: textStyle1))
        }
        
        talkTextView.attributedText = text
        nameLabel.text = data.creator?.name ?? "unknown people".localized
        self.porfileImageView.kf.setImage(with: data.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
    }
}
