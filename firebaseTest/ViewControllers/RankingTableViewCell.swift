//
//  RankingTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/25.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class RankingTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var valueLabel:UILabel!
    
    fileprivate var userId:String? = nil
    
    fileprivate var user:UserInfo? {
        if let id = userId {
            return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: id)
        }
        return nil
    }

    fileprivate var rankingType:UserInfo.RankingType? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let id = self.userId {
            setData(userId: id, rankingType: self.rankingType)
        }
    }
    
    func setData(userId:String?, rankingType:UserInfo.RankingType?) {
        self.rankingType = rankingType
        self.userId = userId
        
        profileImageView.kf.setImage(with: user?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = user?.name
        switch rankingType {
        case .count_of_ad:
            valueLabel.text = user?.count_of_ad.decimalForamtString
        case .count_of_like:
            valueLabel.text = user?.count_of_like.decimalForamtString
        case .count_of_gamePlay:
            valueLabel.text = user?.count_of_gamePlay.decimalForamtString
        case .sum_points_of_gameWin:
            valueLabel.text = user?.sum_points_of_gameWin.decimalForamtString
        case .sum_points_of_gameLose:
            valueLabel.text = user?.sum_points_of_gameLose.decimalForamtString
        case .point:
            valueLabel.text = user?.point.decimalForamtString
        case .exp:
            let a = NSAttributedString(string: " : ", attributes: [
                .foregroundColor : UIColor.autoColor_weak_text_color,
                .font : UIFont.systemFont(ofSize: 12)]
            )
            let space = NSAttributedString(string: " ")
            
            let str = NSMutableAttributedString()
            str.append(NSAttributedString(string: "exp".localized, attributes: [
                .foregroundColor : UIColor.autoColor_text_color,
                .font : UIFont.systemFont(ofSize: 12)
            ]))
            str.append(a)
            str.append(NSAttributedString(string: (user?.exp ?? 0).decimalForamtString, attributes: [
                .foregroundColor : UIColor.autoColor_bold_text_color,
                .font : UIFont.systemFont(ofSize: 12)]
            ))
            str.append(space)
            str.append(NSAttributedString(string: "level".localized, attributes:[
                .foregroundColor : UIColor.autoColor_text_color,
                .font : UIFont.systemFont(ofSize: 12)]
            ))
            str.append(a)
            str.append(NSAttributedString(string: Exp(user?.exp ?? 0).level.decimalForamtString , attributes: [
                .foregroundColor : UIColor.autoColor_bold_text_color,
                .font : UIFont.boldSystemFont(ofSize: 30)]
            ))
            valueLabel.attributedText = str
        case .none:
            break
        }
    }
    
}
