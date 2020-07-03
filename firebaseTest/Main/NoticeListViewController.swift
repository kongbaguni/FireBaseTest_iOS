//
//  NoticeListViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/26.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class NoticeListViewController: UITableViewController {
    static var viewController : NoticeListViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "noticeList") as! NoticeListViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "noticeList") as! NoticeListViewController
        }
    }
    
    @IBOutlet var emptyView: UIView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyView.setEmptyViewFrame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "notice".localized
        NotificationCenter.default.addObserver(forName: .noticeUpdateNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.reloadData()
        }
        if Consts.isAdmin {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchAddBtn(_:)))
        }
        view.addSubview(emptyView)
        emptyView.setEmptyViewFrame()
        reloadData()
    }
    
    @objc func onTouchAddBtn(_ sender: UIBarButtonItem) {
        let vc = PostNoticeViewController.viewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    var notices:Results<NoticeModel> {
        var result = try! Realm().objects(NoticeModel.self).sorted(byKeyPath: "updateDtTimeinterval1970", ascending: false)
        if !Consts.isAdmin {
            result = result.filter("isShow = %@", true)
        }
        return result
    }
    
    private func reloadData() {
        tableView.reloadData()
        emptyView.isHidden = self.notices.count > 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notice = notices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoticeListTableViewCell
        cell.titleLabel.text = notice.title
        cell.dateLabel.text = Date(timeIntervalSince1970: notice.updateDtTimeinterval1970).simpleFormatStringValue
        if Consts.isAdmin {
            cell.accessoryType = notice.isShow ? .checkmark : .none
        } else {
            cell.accessoryType = notice.isRead ? .checkmark : .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notice = notices[indexPath.row]
        let vc = NoticeViewController.viewController
        vc.noticeId = notice.id
        present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions:[UIContextualAction] = []
        let id  = notices[indexPath.row].id
        let detailAction = UIContextualAction(style: .normal, title: "delete".localized, handler: { (action, view, complete)  in
            var notice: NoticeModel? {
                try! Realm().object(ofType: NoticeModel.self, forPrimaryKey: id)
            }
            notice?.delete(complete: {[weak self](sucess) in
                if sucess {
                    if let n = notice {
                        let realm = try! Realm()
                        realm.beginWrite()
                        realm.delete(n)
                        try! realm.commitWrite()
                        self?.reloadData()
                    }
                }
            })
            
        })
        detailAction.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.6, alpha: 1)
        actions.append(detailAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
}

class NoticeListTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
}
