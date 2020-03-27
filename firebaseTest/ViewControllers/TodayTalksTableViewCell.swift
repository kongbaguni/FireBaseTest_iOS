//
//  TodayTalksTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
fileprivate var textStyle0:[NSAttributedString.Key:Any] {
    [
        .font               : UIFont.systemFont(ofSize: 18),
        .foregroundColor    : UIColor.autoColor_text_color
    ]
}

fileprivate var textStyle1:[NSAttributedString.Key:Any] {
    [
        .font               : UIFont.systemFont(ofSize: 10),
        .foregroundColor    : UIColor.autoColor_text_color
    ]
}

fileprivate var textStyle2:[NSAttributedString.Key:Any] {
    [
        .font               : UIFont.boldSystemFont(ofSize: 10),
        .foregroundColor    : UIColor.autoColor_bold_text_color
    ]
}

class TodayTalksTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleImageView:UIImageView!
    @IBOutlet weak var porfileImageView:UIImageView!
    @IBOutlet weak var talkTextView:UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var talkId:String = "" {
        didSet {
            setData()
        }
    }
    
    var data:TalkModel? {
        return try? Realm().object(ofType: TalkModel.self, forPrimaryKey: talkId)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }

    fileprivate func setData() {
        guard let data = self.data else {
            return
        }
        nameLabel.text = data.creator?.name ?? data.creatorId
        self.porfileImageView.kf.setImage(with: data.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))

        switch reuseIdentifier {
        case "myCell","myImageCell":
            bubbleImageView.image = .myBubble
        default:
            bubbleImageView.image = .bubble
        }
        self.bubbleImageView.alpha = data.isDeleted ? 0.5 : 1
        talkTextView.textColor = .autoColor_text_color
        if data.isDeleted {
            talkTextView.text = "deleted talk".localized
            talkTextView.textColor = .autoColor_weak_text_color
            return
        }
        let text = NSMutableAttributedString()
        
        if let txt = data.editList.last?.text {
            text.append(NSAttributedString(string: txt, attributes: textStyle0))
        } else {
            text.append(NSAttributedString(string: data.text, attributes: textStyle0))
        }

        text.append(NSAttributedString(string: "\n\n"))
        if data.likes.count > 0 {
            text.append(NSAttributedString(string: "like : ".localized, attributes: textStyle2))
            text.append(NSAttributedString(string: "\(data.likes.count)", attributes: textStyle1))
            text.append(NSAttributedString(string: "\n"))
        }
        text.append(NSAttributedString(string: "reg : ".localized, attributes: textStyle2))
        text.append(NSAttributedString(string: "\(data.regDt.relativeTimeStringValue)", attributes: textStyle1))

        if let editDt = data.editList.last?.regDt.relativeTimeStringValue {
            text.append(NSAttributedString(string: "\n"))
            text.append(NSAttributedString(string: "edit : ".localized, attributes: textStyle2))
            text.append(NSAttributedString(string: "\(editDt)", attributes: textStyle1))
        }
        
        talkTextView.attributedText = text
    }
}

class TodayTalksTableImageViewCell :TodayTalksTableViewCell {
    @IBOutlet weak var attachmentImageView:UIImageView!
    
    override func setData() {
        guard let data = self.data else {
            return
        }
        super.setData()
        if data.editList.count == 0 {
            attachmentImageView.setImageUrl(url: data.imageUrl, placeHolder: #imageLiteral(resourceName: "placeholder"))
        }
        else {
            if let url = data.editList.last?.imageUrl {
                if data.editList.last?.isImageDeleted == true {
                    attachmentImageView.image = #imageLiteral(resourceName: "placeholder")
                } else {
                    attachmentImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
                }
            }
        }
    }
    
}
