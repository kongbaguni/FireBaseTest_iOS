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
    
    func setData(data:TalkModel) {
        dateLabel.text = data.regDtStr
        talkLabel.text = data.text
        if let user = try! Realm().object(ofType: UserInfo.self, forPrimaryKey: data.creatorId) {
            self.porfileImageView.kf.setImage(with: user.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        }
    }
}
