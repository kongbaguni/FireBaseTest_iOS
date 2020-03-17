//
//  TalkDetailEditHistoryCardDackTavleViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
class TalkDetailEditHistoryCardDackTavleViewCell: UITableViewCell {
    var talkId:String? = nil
    var talkModel:TalkModel? {
        if let id = talkId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    @IBOutlet weak var cardDackView:CardDackView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardDackView.myCards = talkModel?.cardSet
        cardDackView.delarCards = talkModel?.cardSet
        cardDackView.gameResultLabel.text = talkModel?.text
    }
}

class TalkDetailEditHistoryHoldemTableViewCell : UITableViewCell {
    var talkId:String? = nil
    var talkModel:TalkModel? {
        if let id = talkId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    @IBOutlet weak var holdemView:HoldemView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        holdemView.setDataWithHoldemResult(result: talkModel?.holdemResult)
    }

}
