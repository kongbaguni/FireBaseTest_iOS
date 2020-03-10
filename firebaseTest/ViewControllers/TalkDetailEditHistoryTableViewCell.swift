//
//  TalkDetailEditHistoryTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
class TalkDetailEditHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var textView:UITextView!
    
    func setData(data:TextEditModel) {
        dateLabel.text = data.regDtStr
        textView.text = data.text
        textView.textColor = .text_color
    }
}
