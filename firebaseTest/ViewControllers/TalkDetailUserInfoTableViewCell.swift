//
//  TalkDetailUserInfoTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

class TalkDetailUserInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var introduceLabel:UILabel!
    
    func setData(info:UserInfo) {
        profileImageView.kf.setImage(with: info.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = info.name
        introduceLabel.text = info.introduce
    }
}
