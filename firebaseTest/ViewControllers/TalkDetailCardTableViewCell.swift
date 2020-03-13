//
//  TalkDetailCardTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift

class TalkDetailCardTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleImageView:UIImageView!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var cardDack:CardDackView!
    @IBOutlet weak var nameLabel:UILabel!
    
    var talkId:String? = nil
    
    fileprivate var talkModel:TalkModel? {
        if let id = talkId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch reuseIdentifier {
        case "myCardCell":
            bubbleImageView.image = UIApplication.shared.isDarkMode ? #imageLiteral(resourceName: "myBubble_dark") : #imageLiteral(resourceName: "myBubble_light")
        default:
            bubbleImageView.image = UIApplication.shared.isDarkMode ? #imageLiteral(resourceName: "bubble_dark") : #imageLiteral(resourceName: "bubble_light")
        }

        guard let talk = talkModel , let cardset = talk.cardSet, let d_cardSet = talk.delarCardSet else {
            return
        }
        profileImageView.kf.setImage(with: talkModel?.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = talk.creator?.name
        cardDack.myCards = cardset
        cardDack.delarCards = d_cardSet
        cardDack.gameResultLabel.text = talk.text
    }
    
}
