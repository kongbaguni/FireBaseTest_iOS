//
//  TalkDetailHoldemTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/17.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
class TalkDetailHoldemTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleImageView:UIImageView!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var holdemView:HoldemView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    
    var talkId:String? = nil {
        didSet {
            setData()
        }
    }
    
    fileprivate var talkModel:TalkModel? {
        if let id = talkId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }
    
    fileprivate func setData() {
        switch reuseIdentifier {
        case "myHoldemCell":
            bubbleImageView.image = UIApplication.shared.isDarkMode ? #imageLiteral(resourceName: "myBubble_dark") : #imageLiteral(resourceName: "myBubble_light")
        default:
            bubbleImageView.image = UIApplication.shared.isDarkMode ? #imageLiteral(resourceName: "bubble_dark") : #imageLiteral(resourceName: "bubble_light")
        }
        
        guard let talk = talkModel else {
            return
        }
        profileImageView.kf.setImage(with: talkModel?.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = talk.creator?.name
        
        holdemView.setDataWithHoldemResult(result: talkModel?.holdemResult)
        titleLabel.text = talk.holdemResult?.gameResult.rawValue.localized
    }
}

