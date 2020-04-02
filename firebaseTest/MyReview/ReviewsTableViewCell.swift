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

    @IBOutlet weak var imageCollectionView:UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starPointLabel: UILabel!
    @IBOutlet weak var imageCollectionViewWidth: NSLayoutConstraint!
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
        imageCollectionView.dataSource = self
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
        imageCollectionView.setBorder(borderColor: .autoColor_text_color, borderWidth: 0.5, radius: 10, masksToBounds: true)
        loadData()
    }
    
    func loadData() {
        let photoCount = review?.photoUrlList.count ?? 0
        imageCollectionView.isHidden = photoCount == 0
        imageCollectionViewWidth.constant = CGFloat(photoCount * 80)
        imageCollectionView.isScrollEnabled = false
        if photoCount > 1 {
            imageCollectionViewWidth.constant = CGFloat(80 + 40)
            imageCollectionView.isScrollEnabled = true
        }
        
        titleLabel.text = review?.name
        let point = review?.starPoint ?? 0
        if point <= Consts.stars.count && point > 0 {
            starPointLabel.text = Consts.stars[point-1]
        }
        priceLaebl.text = review?.price.currencyFormatString
        commentLabel.text = review?.comment
        let likeCount = review?.likeList.count ?? 0
        let msg = String(format:"like : %@".localized, likeCount.decimalForamtString)
        likeBtn.setTitle(msg, for: .normal)
    }
}

extension ReviewsTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ReviewImageCollectionViewCell
        if let list = review?.photoUrlList {
            let url = list[indexPath.row]
            cell.imageView.kf.setImage(with: url,placeholder: UIImage.placeHolder_image)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return review?.photoUrlList.count ?? 0
    }
    
}


class ReviewImageCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
}
