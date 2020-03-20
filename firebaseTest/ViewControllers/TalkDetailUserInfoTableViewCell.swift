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
    
    var userId:String? = nil {
        didSet {
            setData()
        }
    }
    
    var likeId:String? = nil {
        didSet {
            setData()
        }
    }
    
    var likeModel:LikeModel? {
        if let id = likeId {
            return try? Realm().object(ofType: LikeModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    var userInfo:UserInfo? {
        if let id = userId {
            return try? Realm().object(ofType: UserInfo.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }
    
    fileprivate func setData() {
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
