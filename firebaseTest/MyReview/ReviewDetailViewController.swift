//
//  ReviewDetailViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import MapKit

class ReviewDetailViewController: UITableViewController {
    var reviewId:String? = nil
    var review:ReviewModel? {
        if let id = reviewId {
            return try? Realm().object(ofType: ReviewModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    deinit {
        print("deinit ReviewDetailViewController")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self](_) in
            self?.tableView.reloadData()
        }
        title = review?.name
    }    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return review?.photoUrlList.count ?? 0
        case 2:
            return 5
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profile", for: indexPath) as! ReviewDetailProfileTableViewCell
            cell.profileImageView.kf.setImage(with: review?.creator?.profileImageURL, placeholder: UIImage.placeHolder_profile)
            cell.nameLabel.text = review?.creator?.name
            cell.dateLabel.text = review?.regDt.simpleFormatStringValue
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "photo", for: indexPath) as! ReviewDetailPhotoTableViewCell
            if let photo = review?.photoUrlList[indexPath.row] {
                cell.imageUrl = photo
            }
            return cell
        case 2:
            switch indexPath.row {
            case 0: // 내용
                let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                cell.textLabel?.text = review?.comment
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
                cell.textLabel?.text = "price".localized
                cell.detailTextLabel?.text = review?.price.currencyFormatString
                return cell
            case 2: // 별점
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
                cell.textLabel?.text = "starPoint".localized
                cell.detailTextLabel?.text = nil
                if let point = review?.starPoint {
                    if point > 0 && point <= Consts.stars.count {
                        cell.detailTextLabel?.text = Consts.stars[point-1]
                    }
                }
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
                cell.textLabel?.text = "regDt".localized
                cell.detailTextLabel?.text = review?.regDt.simpleFormatStringValue
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "map", for: indexPath) as! ReviewsMapCellTableViewCell
                cell.setDefaultPostion()
                if let id = self.reviewId {
                    cell.setAnnotation(reviewIds: [id], isForce: false)
                }
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class ReviewDetailProfileTableViewCell : UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
}

class ReviewDetailPhotoTableViewCell : UITableViewCell {
    @IBOutlet weak var photoImageView:UIImageView!
    @IBOutlet weak var imageViewLayoutHeight: NSLayoutConstraint!
    var imageUrl:URL? = nil {
        didSet {
            setImage()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setImageViewLayout()
    }
    
    func setImage() {
        photoImageView?.kf.setImage(with: imageUrl, placeholder: UIImage.placeHolder_image, options: nil, progressBlock: nil
            , completionHandler: { [weak self] (_) in
                self?.setImageViewLayout()
        })
    }
    
    func setImageViewLayout() {
        guard
            let size = photoImageView?.image?.size else {
            return
        }
        let targetWidth = photoImageView.frame.size.width
        let targetSize = CGSize(width: targetWidth, height: targetWidth)
        let newSize = size.resize(target: targetSize, isFit: true)
        imageViewLayoutHeight.constant = newSize.height
    }
}

