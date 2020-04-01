//
//  ReviewsViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/31.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ReviewsViewController : UITableViewController {
    static var viewController : ReviewsViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(identifier: "reviews") as! ReviewsViewController
        } else {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(withIdentifier: "reviews") as! ReviewsViewController
        }
    }
    
    var reviews:Results<ReviewModel>? {
        guard let lng = UserDefaults.standard.lastMyCoordinate?.longitude,
            let lat = UserDefaults.standard.lastMyCoordinate?.latitude else {
                return nil
        }
        let minlat = lat - 0.005
        let maxlat = lat + 0.005
        let minlng = lng - 0.005
        let maxlng = lng + 0.005
        return try! Realm().objects(ReviewModel.self)
            .filter("lat > %@ && lat < %@ && lng > %@ && lng < %@",minlat, maxlat, minlng, maxlng)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func viewDidLoad() {
        title = "Review".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupRightBarButtonItem(_:)))
        NotificationCenter.default.addObserver(forName: .reviewWriteNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .reviewEditNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.tableView.reloadData()
        }
        
        refreshControl?.addTarget(self, action: #selector(self.onRefreshControll(_:)), for: .valueChanged)
        
        self.onRefreshControll(UIRefreshControl())
        
        LocationManager.shared.requestAuth(complete: { (status) in
            
        }) { (location) in
            self.tableView.reloadData()
        }

    }
    
    let loading = Loading()
    @objc func onRefreshControll(_ sender: UIRefreshControl) {
        if sender != self.refreshControl {
            loading.show(viewController: self)
        }
        ReviewModel.sync { [weak self](sucess) in
            sender.endRefreshing()
            self?.loading.hide()
            self?.tableView.reloadData()
        }
    }
    
    @objc func onTouchupRightBarButtonItem(_ sender:UIBarButtonItem) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.popoverPresentationController?.barButtonItem = sender
        vc.addAction(UIAlertAction(title: "myProfile".localized, style: .default, handler: { (_) in
            let vc = MyProfileViewController.viewController
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        
        if Consts.isAdmin {
            vc.addAction(UIAlertAction(title: "admin menu".localized, style: .destructive, handler: { (action) in
                let vc = AdminViewController.viewController
                self.navigationController?.pushViewController(vc, animated: true)
            }))
        }
        
        vc.addAction(UIAlertAction(title: "write review", style: .default, handler: { (_) in
            let vc = MyReviewWriteController.viewController
            self.navigationController?.pushViewController(vc, animated: true)
            
        }))
        vc.addAction(UIAlertAction(title: "logout".localized, style: .default, handler: { (_) in
            UserInfo.info?.logout()
        }))
        
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return reviews?.count ?? 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if let list = reviews {
                let id = list[indexPath.row].id
                let vc = MyReviewWriteController.viewController
                vc.reviewId = id
                self.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "map", for: indexPath) as! ReviewsMapCellTableViewCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "review", for: indexPath)
            if let data = reviews {
                cell.textLabel?.text = data[indexPath.row].name
            }
            return cell
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.shared.manager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.shared.manager.stopUpdatingLocation()
    }
}


