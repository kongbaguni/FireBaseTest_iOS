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
    var editLogID:String? = nil {
        didSet {
            setData()
        }
    }
    
    var data:TextEditModel? {
        if let id = editLogID {
            return try? Realm().object(ofType: TextEditModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }
    
    fileprivate func setData() {
        textView.textColor = .autoColor_text_color
        guard let data = self.data else {
            return
        }
        dateLabel.text = data.regDt.simpleFormatStringValue
        textView.text = data.text
    }
}

class TalkDetailEditHistoryImageTableViewCell : TalkDetailEditHistoryTableViewCell {
    @IBOutlet weak var attachmentImageView: UIImageView!
    override func setData() {
        super.setData()
        guard let data = self.data else {
            return
        }
        attachmentImageView.kf.setImage(with: data.imageUrl, placeholder: #imageLiteral(resourceName: "placeholder"))
    }
}

