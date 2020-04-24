//
//  TalkDetailHoldemTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/17.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift

class TalkDetailHoldemTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleImageView:UIImageView!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var holdemView:HoldemView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var likeBtn:UIButton!
    let disposeBag = DisposeBag()
    
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
        if likeBtn.tag != 112233 {
            likeBtn.rx.tap.bind { [weak self](_) in
                self?.likeBtn.isEnabled = false
                self?.talkModel?.toggleLike(complete: { (sucess) in
                    self?.likeBtn.isEnabled = true
                    self?.setData()
                })
            }.disposed(by: disposeBag)
            likeBtn.tag = 112233
        }
    }
    
    fileprivate func setData() {
        switch reuseIdentifier {
        case "myHoldemCell":
            bubbleImageView.image = .myBubble
        default:
            bubbleImageView.image = .bubble
        }
        
        guard let talk = talkModel else {
            return
        }
        
        let format = talk.isLike ? "liked : %@" :"like : %@"
        likeBtn.setTitle(String(format: format.localized, talk.likes.count.decimalForamtString), for: .normal)
        likeBtn.setTitle("processing...".localized, for: .disabled)
        likeBtn.setTitleColor(talk.isLike ? .autoColor_bold_text_color : .autoColor_text_color, for: .normal)
        likeBtn.setTitleColor(.autoColor_weak_text_color, for: .disabled)
        
        profileImageView.kf.setImage(with: talkModel?.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = talk.creator?.name
        
        holdemView.setDataWithHoldemResult(result: talkModel?.holdemResult)
        titleLabel.text = talk.holdemResult?.gameResult.rawValue.localized
    }
}

