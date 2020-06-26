//
//  TodayTalksTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa
extension Notification.Name {
    static let todayTlakImageBtnTouchup = Notification.Name("todayTalkImageBtnTouchup")
}

fileprivate var textStyle0:[NSAttributedString.Key:Any] {
    [
        .font               : UIFont.systemFont(ofSize: 18),
        .foregroundColor    : UIColor.autoColor_text_color
    ]
}

fileprivate var textStyle1:[NSAttributedString.Key:Any] {
    [
        .font               : UIFont.systemFont(ofSize: 10),
        .foregroundColor    : UIColor.autoColor_text_color
    ]
}

fileprivate var textStyle2:[NSAttributedString.Key:Any] {
    [
        .font               : UIFont.boldSystemFont(ofSize: 10),
        .foregroundColor    : UIColor.autoColor_bold_text_color
    ]
}

class TodayTalksTableViewCell: UITableViewCell {
    @IBOutlet weak var bubbleImageView:UIImageView!
    @IBOutlet weak var porfileImageView:UIImageView!
    @IBOutlet weak var talkTextView:UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likeBtn:UIButton!
    let disposeBag = DisposeBag()
    var talkId:String = "" {
        didSet {
            setData()
        }
    }
    
    var data:TalkModel? {
        return try? Realm().object(ofType: TalkModel.self, forPrimaryKey: talkId)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
    
        if likeBtn.tag != 112233 {
            likeBtn.rx.tap.bind { [weak self](_) in
                self?.likeBtn.isEnabled = false
                self?.data?.toggleLike(complete: { (sucess) in
                    self?.likeBtn.isEnabled = true
                    self?.setData()
                })
            }.disposed(by: disposeBag)
            likeBtn.tag = 112233
        }
        addObserver()
    }
    
    
    var isObserverAdded = false
    func addObserver() {
        if isObserverAdded {
            return
        }
        NotificationCenter.default.addObserver(forName: .likeUpdateNotification, object: nil, queue: nil) { [weak self](_) in
            self?.setData()
        }
        isObserverAdded = true
    }
    


    fileprivate func setData() {
        
        guard let data = self.data else {
            return
        }
        let format = data.isLike ?  "liked : %@" : "like : %@"
        likeBtn.setTitle("processing...".localized, for: .disabled)
        likeBtn.setTitle(String(format: format.localized, data.likes.count.decimalForamtString), for: .normal)
        likeBtn.setTitleColor(data.isLike ? .autoColor_bold_text_color : .autoColor_text_color, for: .normal)
        likeBtn.setTitleColor(.autoColor_weak_text_color, for: .disabled)
        nameLabel.text = data.creator?.name ?? data.creatorId
        self.porfileImageView.kf.setImage(with: data.creator?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))

        switch reuseIdentifier {
        case "myCell","myImageCell":
            bubbleImageView.image = .myBubble
        default:
            bubbleImageView.image = .bubble
        }
        bubbleImageView.alpha = (data.isDeleted || data.isDeletedByAdmin) ? 0.5 : 1
        talkTextView.alpha = (data.isDeleted || data.isDeletedByAdmin) ? 0.5 : 1
        talkTextView.textColor = .autoColor_text_color
        if data.isDeleted {
            talkTextView.attributedText = NSAttributedString(string: "deleted talk".localized, attributes: textStyle1)
            return
        }
        if data.isDeletedByAdmin {
            talkTextView.attributedText = NSAttributedString(string: "deleted by Admin".localized, attributes: textStyle1)
            return

        }
        let text = NSMutableAttributedString()
        if let txt = data.editList.last?.text {
            text.append(NSAttributedString(string: txt, attributes: textStyle0))
        } else {
            text.append(NSAttributedString(string: data.text, attributes: textStyle0))
        }

        text.append(NSAttributedString(string: "\n\n"))
        text.append(NSAttributedString(string: "reg : ".localized, attributes: textStyle2))
        text.append(NSAttributedString(string: "\(data.regDt.relativeTimeStringValue)", attributes: textStyle1))

        if let editDt = data.editList.last?.regDt.relativeTimeStringValue {
            text.append(NSAttributedString(string: "\n"))
            text.append(NSAttributedString(string: "edit : ".localized, attributes: textStyle2))
            text.append(NSAttributedString(string: "\(editDt)", attributes: textStyle1))
        }
        
        talkTextView.attributedText = text
    }
}

class TodayTalksTableImageViewCell :TodayTalksTableViewCell {
    @IBOutlet weak var attachmentImageView:UIImageView!
    @IBOutlet weak var imageOverBtn:UIButton!
    
    override func setData() {
        guard let data = self.data else {
            return
        }
        super.setData()
        if data.editList.count == 0 {
            attachmentImageView.kf.setImage(with: data.thumbURL, placeholder: UIImage.placeHolder_image)
        }
        else {
            if let url = data.editList.last?.imageUrl {
                if data.editList.last?.isImageDeleted == true {
                    attachmentImageView.image = #imageLiteral(resourceName: "placeholder")
                } else {
                    attachmentImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
                }
            }
        }
        
        imageOverBtn.rx.tap.bind { [weak self](_) in
            let url = self?.data?.imageURL
            NotificationCenter.default.post(name: .todayTlakImageBtnTouchup, object: url)
        }.disposed(by: disposeBag)
    }
    
}
