//
//  TalkDetailEditHistoryCardDackTavleViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift

@available(*, deprecated, message: "삭제 예정")
class TalkDetailEditHistoryCardDackTavleViewCell: UITableViewCell {
    var talkId:String? = nil
    var talkModel:TalkModel? {
        if let id = talkId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    @IBOutlet weak var cardDackView:CardDackView!
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
    @IBOutlet weak var titleLabel:UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        holdemView.setDataWithHoldemResult(result: talkModel?.holdemResult)
        titleLabel.text = talkModel?.holdemResult?.gameResult.rawValue.localized
    }

}
