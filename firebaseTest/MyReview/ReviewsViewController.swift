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
import RxSwift
import RxCocoa

extension Notification.Name {
    static let reviews_selectReviewInReviewList = Notification.Name("reviews_selectReviewInReviewList_observer")
}

class ReviewsViewController : UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let disposeBag = DisposeBag()
    
    static var viewController : ReviewsViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(identifier: "reviews") as! ReviewsViewController
        } else {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(withIdentifier: "reviews") as! ReviewsViewController
        }
    }
    
    var searchText:String? = nil
    
    var reviews:Results<ReviewModel>? {
        guard let lng = UserDefaults.standard.lastMyCoordinate?.longitude,
            let lat = UserDefaults.standard.lastMyCoordinate?.latitude else {
                return nil
        }
        let minlat = lat - 0.005
        let maxlat = lat + 0.005
        let minlng = lng - 0.005
        let maxlng = lng + 0.005
        var result = try! Realm().objects(ReviewModel.self)
            .filter("reg_lat > %@ && reg_lat < %@ && reg_lng > %@ && reg_lng < %@",minlat, maxlat, minlng, maxlng)
        
        if let txt = searchText?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) {
            if txt.isEmpty == false {
                result = result.filter("name CONTAINS[c] %@ || comment CONTAINS[C] %@", txt, txt)
            }
        }
        return result
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidLoad() {
        title = "review".localized
        searchBar.placeholder = "search review".localized
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        
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
        searchBar.rx.text.orEmpty.bind { [weak self] (string) in
            self?.searchText = string
            self?.tableView.reloadData()
        }.disposed(by: disposeBag)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showReviewDetail":
            if let vc = segue.destination as? ReviewDetailViewController {
                vc.reviewId = sender as? String
            }
            break
        default:
            break
        }
    }
    
    let loading = Loading()
    @objc func onRefreshControll(_ sender: UIRefreshControl) {
        if sender != self.refreshControl {
            loading.show(viewController: self)
        }
        var ids:[String] = []
        if let list = self.reviews {
            for review in list {
                ids.append(review.id)
            }
        }
        
        ReviewModel.sync { [weak self](sucess) in
            sender.endRefreshing()
            self?.loading.hide()
            self?.tableView.reloadData()
            
            NotificationCenter.default.post(
                name: .reviews_selectReviewInReviewList,
                object: nil,
                userInfo: ["ids":ids ,"isForce":false])
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
        
        vc.addAction(UIAlertAction(title: "write review".localized, style: .default, handler: { (_) in
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
        return reviews?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let list = reviews {
            let id = list[indexPath.row].id
            self.performSegue(withIdentifier: "showReviewDetail", sender: id)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "review", for: indexPath) as! ReviewsTableViewCell
        if let data = reviews {
            cell.reviewId = data[indexPath.row].id
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.shared.manager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.shared.manager.stopUpdatingLocation()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let list = self.reviews else {
            return nil
        }

        var action:[UIContextualAction] = []
        let id = list[indexPath.row].id

        if UserInfo.info?.id == reviews?[indexPath.row].creatorId {
            action.append(UIContextualAction(style: .normal, title: "edit".localized, handler: { (action, view, complete) in
                    let vc = MyReviewWriteController.viewController
                    vc.reviewId = id
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            ))
        }
        
        return UISwipeActionsConfiguration(actions: action)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }        
    
}


