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

class ReviewHistoryTableViewController: UITableViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "edit history".localized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return edits?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if edits?[section].photoUrlList.count == 0 {
            return 6            
        }
        return 7
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let data = edits?[section]
        return data?.modifiedDt?.simpleFormatStringValue
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = edits?[indexPath.section]
        
        var before:ReviewEditModel? = nil
        if indexPath.section > 0 {
            before = edits?[indexPath.section - 1]
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            if let lat = data?.location?.latitude,
                let lng = data?.location?.longitude {
                cell.textLabel?.text = "latitude:\(lat)\nlongitude:\(lng)"
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = data?.addressStringValue
            if before?.addressStringValue != data?.addressStringValue {
                cell.textLabel?.alpha = 1
            } else {
                cell.textLabel?.alpha = 0.3
            }
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = data?.name
            if before?.name != data?.name {
                cell.textLabel?.alpha = 1
            } else {
                cell.textLabel?.alpha = 0.3
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = data?.price.currencyFormatString
            if before?.price != data?.price {
                cell.textLabel?.alpha = 1
            } else {
                cell.textLabel?.alpha = 0.3
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = nil
            let point = data?.starPoint ?? -1
            if point <= Consts.stars.count && point >= 0 {
                cell.textLabel?.text = Consts.stars[point-1]
            }
            if before?.starPoint != data?.starPoint {
                cell.textLabel?.alpha = 1
            } else {
                cell.textLabel?.alpha = 0.3
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.textLabel?.text = data?.comment
            if before?.comment != data?.comment {
                cell.textLabel?.alpha = 1
            } else {
                cell.textLabel?.alpha = 0.3
            }
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ReviewHistoryImageTableViewCell
            cell.images = data?.photoUrlList ?? []
            print(cell.images.count)
            if before?.photoUrlList != data?.photoUrlList {
                cell.collectionView.alpha = 1
            } else {
                cell.collectionView.alpha = 0.3
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let title = indexPath.section == 0 ? "posting location".localized : "editing location".localized
            let vc = PopupMapViewController.viewController(coordinate: review?.location, title:title, annTitle: nil)
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
