//
//  ReviewHistoryTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/17.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxSwift
import RxCocoa


class ReviewHistoryTableViewController: UITableViewController {
    @IBOutlet weak var optionSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    var reviewId:String? = nil
    var review:ReviewModel? {
        if let id = reviewId {
            return try! Realm().object(ofType: ReviewModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    var edits:Results<ReviewEditModel>? {
        return review?.editList.sorted(byKeyPath: "modifiedTimeIntervalSince1970")
    }
    
    let disposeBag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "edit history".localized
        optionSwitch.isOn = UserDefaults.standard.showModifiedOnly
        optionSwitch.rx.isOn.bind { [weak self](isOn) in
            UserDefaults.standard.showModifiedOnly = isOn
            self?.tableView.reloadData()
        }.disposed(by: disposeBag)
        switchLabel.text = "show modified only".localized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return edits?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if edits?[section].photos.count == 0 {
            return 6
        }
        return 7
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let data = edits?[section]

        var strA:String {
            switch section {
            case 0:
                return "Creation time".localized
            default:
                return "modification time".localized
            }
        }
        
        if let value = data?.modifiedDt?.simpleFormatStringValue  {
            return "\(strA) : \(value)"
        }
    
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if optionSwitch.isOn == false {
            return UITableView.automaticDimension
        }
        if isChange(indexPath: indexPath)  {
            return UITableView.automaticDimension
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func isChange(indexPath:IndexPath)->Bool {
        let data = edits?[indexPath.section]
        if indexPath.section == 0 {
            return true
        }
        let before = edits?[indexPath.section - 1]

        switch indexPath.row {
        case 0:
            return true
        case 1:
            return before?.addressStringValue != data?.addressStringValue
        case 2:
            return before?.name != data?.name
        case 3:
            return before?.price != data?.price
        case 4:
            return before?.starPoint != data?.starPoint
        case 5:
            return before?.comment != data?.comment
        case 6:
            return before?.photos != data?.photos
        default:
            break
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = edits?[indexPath.section]
        let isChange = self.isChange(indexPath: indexPath)
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ReviewHistroyBasicTableViewCell
            if let lat = data?.location?.latitude,
                let lng = data?.location?.longitude {
                cell.titleLabel.text = "place".localized
                cell.detailLabel.text = "latitude:\(lat)\nlongitude:\(lng)"
                cell.contentView.alpha = isChange ? 1.0 : 0.3
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ReviewHistroyBasicTableViewCell
            cell.titleLabel.text = "address".localized
            cell.detailLabel.text = data?.addressStringValue
            cell.contentView.alpha = isChange ? 1.0 : 0.3
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ReviewHistroyBasicTableViewCell
            cell.titleLabel.text = "name".localized
            cell.detailLabel.text = data?.name
            cell.contentView.alpha = isChange ? 1.0 : 0.3
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ReviewHistroyBasicTableViewCell
            cell.titleLabel.text = "price".localized
            cell.detailLabel.text = data?.priceLocaleString
            cell.contentView.alpha = isChange ? 1.0 : 0.3
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ReviewHistroyBasicTableViewCell
            cell.titleLabel.text = "starPoint".localized
            cell.detailLabel.text = nil
            let point = data?.starPoint ?? -1
            if point <= Consts.stars.count && point >= 0 {
                cell.detailLabel.text = Consts.stars[point-1]
            }
            cell.contentView.alpha = isChange ? 1.0 : 0.3
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! ReviewHistroyBasicTableViewCell
            cell.titleLabel.text = "comment".localized
            cell.detailLabel.text = data?.comment
            cell.contentView.alpha = isChange ? 1.0 : 0.3
            
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ReviewHistoryImageTableViewCell
            if let photos = data?.photos {
                var images:[URL] = []
                for p in photos {
                    if let url = p.thumbURL {
                        images.append(url)
                    }
                }
                cell.images = images
            }
            
            print(cell.images.count)
            cell.contentView.alpha = isChange ? 1.0 : 0.3
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = edits?[indexPath.section]
        switch indexPath.row {
        case 0:
            let title = indexPath.section == 0 ? "posting location".localized : "editing location".localized
            let vc = PopupMapViewController.viewController(coordinate: review?.location, title:title, annTitle: nil)
            present(vc, animated: true, completion: nil)
        case 1:
            let title = data?.addressStringValue
            let vc = PopupMapViewController.viewController(coordinate: data?.place?.location, title:title, annTitle: nil)
            vc.altitude = data?.place?.viewPortDistance ?? 1500
            present(vc, animated: true, completion: nil)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
}


class ReviewHistoryImageTableViewCell : UITableViewCell {
    @IBOutlet weak var collectionView:UICollectionView!
    var images:[URL] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        collectionView.dataSource = self
    }
}

extension ReviewHistoryImageTableViewCell : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(images.count)
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! ReviewHistoryImageCollectionViewCell
        cell.imageView.kf.setImage(with: images[indexPath.row], placeholder: UIImage.placeHolder_image)
        print(images[indexPath.row].absoluteString)
        return cell
    }
}

class ReviewHistoryImageCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
}

class ReviewHistroyBasicTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var detailLabel:UILabel!
}
