//
//  TalkDetailUserInfoTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift

class TalkDetailUserInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var introduceLabel:UILabel!
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        nameLabel.text = "unknown people".localized
        introduceLabel.text = nil
    }
    
    var userId:String = "" {
        didSet {
            likeId = ""
        }
    }
    var likeId:String = "" {
        didSet {
            userId = ""
        }
    }
    
    var likeModel:LikeModel? {
        return try? Realm().object(ofType: LikeModel.self, forPrimaryKey: likeId)
    }
    
    var userInfo:UserInfo? {
        return try? Realm().object(ofType: UserInfo.self, forPrimaryKey: userId)
    }
    
    override func layoutSubviews() {
        if let info = userInfo {
            profileImageView.kf.setImage(with: info.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
            nameLabel.text = info.name
            introduceLabel.text = info.introduce
        }
        else if let like = likeModel {
            profileImageView.kf.setImage(with: like.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
            nameLabel.text = like.creator?.name
            introduceLabel.text = like.regDt.relativeTimeStringValue
        }
    }    
}
