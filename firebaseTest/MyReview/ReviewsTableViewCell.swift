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

class ReviewsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starPointLabel: UILabel!
    @IBOutlet weak var priceLaebl: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    let disposeBag = DisposeBag()
    
    var reviewId:String? = nil {
        didSet {
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }
    var review:ReviewModel? {
        if let id = reviewId {
            return try! Realm().object(ofType: ReviewModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        likeBtn.rx.tap.bind { (_) in
            self.likeBtn.isEnabled = false
            self.review?.toggleLike(complete: {[weak self] (isLike) in
                self?.likeBtn.isEnabled = true
                self?.loadData()
            })
        }.disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadData()
    }
    
    func loadData() {        
        titleLabel.text = review?.name
        let point = review?.starPoint ?? 0
        if point <= Consts.stars.count && point > 0 {
            starPointLabel.text = Consts.stars[point-1]
        }
        priceLaebl.text = review?.price.currencyFormatString
        commentLabel.text = review?.comment
        let likeCount = review?.likeList.count ?? 0
        var msg = String(format:"like : %@".localized, likeCount.decimalForamtString)
        if review?.likeList.filter("creatorId = %@",UserInfo.info?.id ?? "").count != 0 {
            msg = String(format:"liked : %@".localized, likeCount.decimalForamtString)
        }
        likeBtn.setTitle(msg, for: .normal)
        likeBtn.setTitle("♡ " + "processing...".localized, for: .disabled)
    }
}
