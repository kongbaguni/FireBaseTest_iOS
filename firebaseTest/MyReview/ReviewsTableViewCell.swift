//
//  ReviewsTableViewCell.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/01.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxCocoa
import RxSwift
protocol ReviewTableViewCellDelegate : class {
    func didEditBtnTouched(targetId:String,cell:ReviewsTableViewCell)
    func didReportBtnTouched(targetId:String,cell:ReviewsTableViewCell)
}
class ReviewsTableViewCell: UITableViewCell {

    weak var delegate:ReviewTableViewCellDelegate? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starPointLabel: UILabel!
    @IBOutlet weak var priceLaebl: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var attachImageView: UIImageView!
    @IBOutlet weak var attach2ImageView: UIImageView!
    @IBOutlet weak var attach3ImageView: UIImageView!
    @IBOutlet weak var attach4ImageView: UIImageView!
    @IBOutlet weak var attach5ImageView: UIImageView!
    @IBOutlet weak var attach6ImageView: UIImageView!
    
    @IBOutlet weak var attachPlusLabel: UILabel!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    let disposeBag = DisposeBag()
    
    var reviewId:String? = nil 
    
    var review:ReviewModel? {
        if let id = reviewId {
            return try! Realm().object(ofType: ReviewModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    fileprivate var isSet:Bool = false
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if isSet == false {
            likeBtn.rx.tap.bind { [weak self](_) in
                self?.likeBtn.isEnabled = false
                self?.review?.toggleLike(complete: {[weak self] (isLike) in
                    self?.likeBtn.isEnabled = true
                    self?.loadData()
                })
            }.disposed(by: disposeBag)
            
            NotificationCenter.default.addObserver(forName: .likeUpdateNotification, object: nil, queue: nil) { [weak self](_) in
                self?.loadData()
            }
            isSet = true
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadData()
    }
    
    func loadData() {
        if review?.isDeletedByAdmin == true {
            titleLabel.isHidden = true
            starPointLabel.text = ""
            priceLaebl.text = ""
            imageViewHeight.constant = 0
            commentLabel.text = "deleted by Admin".localized
            return
        }
        let isMyPost = review?.creatorId == UserInfo.info?.id
        editBtn.isHidden = !isMyPost
        reportBtn.isHidden = isMyPost
        
        editBtn.setTitle("edit".localized, for: .normal)
        reportBtn.setTitle("report".localized, for: .normal)
        titleLabel.text = review?.name
        let point = review?.starPoint ?? 0
        if point <= Consts.stars.count && point > 0 {
            starPointLabel.text = Consts.stars[point-1]
        }
        priceLaebl.text = review?.priceLocaleString
        commentLabel.text = review?.comment
        let likeCount = review?.likeList.count ?? 0
        var msg = String(format:"like : %@".localized, likeCount.decimalForamtString)
        if review?.likeList.filter("creatorId = %@",UserInfo.info?.id ?? "").count != 0 {
            msg = String(format:"liked : %@".localized, likeCount.decimalForamtString)
        }
        likeBtn.setTitle(msg, for: .normal)
        likeBtn.setTitle("♡ " + "processing...".localized, for: .disabled)
        
        func setImageView(imageView:UIImageView, count:Int)->Bool {
            if review?.photoUrlList.count ?? 0 > count {
                imageView.kf.setImage(with: review?.photoUrlList[count], placeholder: UIImage.placeHolder_image)
                imageView.isHidden = false
                return true
            } else {
                imageView.isHidden = true
                return false
            }
        }

        _ = setImageView(imageView: attachImageView, count: 0)
        let photoCount = review?.photoUrlList.count ?? 0
        switch photoCount {
        case 0:
            imageViewHeight.constant = 0
        case 1:
            imageViewHeight.constant = 210
        case 2:
            imageViewHeight.constant = 240
        case 3:
            imageViewHeight.constant = 270
        case 4:
            imageViewHeight.constant = 300
        case 5:
            imageViewHeight.constant = 330
        default:
            imageViewHeight.constant = 360
        }

        attach2ImageView.superview?.isHidden =
            !setImageView(imageView: attach2ImageView, count: 1)
        
        _ = setImageView(imageView: attach3ImageView, count: 2)
        
        attach4ImageView.superview?.isHidden =  !setImageView(imageView: attach4ImageView, count: 3)
        
        _ = setImageView(imageView: attach5ImageView, count: 4)
        _ = setImageView(imageView: attach6ImageView, count: 5)
        
        let count = (review?.photoUrlList.count ?? 0) - 6
        attachPlusLabel.isHidden = count <= 0
        attachPlusLabel.text = "+\(count)"
        attachPlusLabel.textColor = .autoColor_bold_text_color
    }
    
    @IBAction func onTouchupBtn(sender:UIButton) {
        switch sender {
        case editBtn:
            delegate?.didEditBtnTouched(targetId: reviewId!, cell: self)
        case reportBtn:
            delegate?.didReportBtnTouched(targetId: reviewId!, cell: self)
        default:
            break
        }
    }
}
