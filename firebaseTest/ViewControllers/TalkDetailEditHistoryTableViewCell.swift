//
//  TalkDetailEditHistoryTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
class TalkDetailEditHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var textView:UITextView!
    var editLogID:String = ""
    var data:TextEditModel? {
        return try? Realm().object(ofType: TextEditModel.self, forPrimaryKey: editLogID)
    }
    
    override func layoutSubviews() {
        dateLabel.text = data?.regDt.simpleFormatStringValue
        textView.text = data?.text
        textView.textColor = .autoColor_text_color
    }
}

class TalkDetailEditHistoryImageTableViewCell : TalkDetailEditHistoryTableViewCell {
    @IBOutlet weak var attachmentImageView: UIImageView!
    override func layoutSubviews() {
        super.layoutSubviews()
        attachmentImageView.kf.setImage(with: data?.imageUrl, placeholder: #imageLiteral(resourceName: "placeholder"))
    }
}

