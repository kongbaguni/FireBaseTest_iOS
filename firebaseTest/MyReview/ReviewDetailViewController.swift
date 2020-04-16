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
import Lightbox

extension Notification.Name {
    static let imageDownloadDidComplee = Notification.Name(rawValue: "imageDownloadDidComplete_observer")
}


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
        NotificationCenter.default.addObserver(forName: .imageDownloadDidComplee, object: nil, queue: nil) { [weak self] (_) in
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = StatusViewController.viewController(withUserId: self.review?.creatorId)
            present(vc, animated: true, completion: nil)
        case 1:
            if let list = review?.photoUrlList {
                let imgs = LightboxImage.getImages(imageUrls: list)
                let vc = LightboxController(images: imgs, startIndex: indexPath.row)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }            
        default:
            tableView.deselectRow(at: indexPath, animated: true)
            break
        }
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
        if let size = ImageInfoModel.getSize(url: imageUrl?.absoluteString) {
            setImageViewLayout(imageSize: size)
        } else {
            ImageInfoModel.getSize(url: imageUrl?.absoluteString) { [weak self](size) in
                self?.setImageViewLayout(imageSize: size)
            }
        }
        
        photoImageView?.kf.setImage(with: imageUrl, placeholder: UIImage.placeHolder_image, options: nil, progressBlock: nil
            , completionHandler: { [weak self] (_) in
                ImageInfoModel.create(url: self?.imageUrl?.absoluteString, size: self?.photoImageView.image?.size)
                self?.setImageViewLayout()
        })
    }
    
    func setImageViewLayout(imageSize:CGSize? = nil) {
        var s = imageSize
        if let ss = photoImageView?.image?.size {
            s = ss
        }
        guard let size = s else {
            return
        }
        let targetWidth = photoImageView.frame.size.width
        let targetSize = CGSize(width: targetWidth, height: targetWidth)
        let newSize = size.resize(target: targetSize, isFit: true)
        imageViewLayoutHeight.constant = newSize.height
    }
        
}
