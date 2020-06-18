//
//  ReportListViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift

class ReportListViewController: UITableViewController {
    
    static var viewController : ReportListViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(identifier: "reportList")
        } else {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(withIdentifier: "reportList") as! ReportListViewController
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    var totalReports:Results<ReportModel> {
        return try! Realm().objects(ReportModel.self).sorted(byKeyPath: "regDtTimeIntervalSince1970").filter("isCheck = %@",false)
    }
    
    var users:Results<ReportModel> {
        return totalReports.filter("targetTypeCode = %@",ReportModel.TargetType.user.rawValue)
    }
    
    var talks:Results<ReportModel> {
        return totalReports.filter("targetTypeCode = %@",ReportModel.TargetType.talk.rawValue)
    }

    var reviews:Results<ReportModel> {
        return totalReports.filter("targetTypeCode = %@",ReportModel.TargetType.review.rawValue)
    }
    
    var blockedUsers:Results<UserInfo> {
        return try! Realm().objects(UserInfo.self).filter("isBlockByAdmin = %@",true).sorted(byKeyPath: "email")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ReportModel.syncReports { [weak self](isSucess) in
            self?.tableView.reloadData()
        }
        title = "report list".localized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return users.count
        case 1:
            return talks.count
        case 2:
            return reviews.count
        case 3:
            return blockedUsers.count
        default:
            return 0
        }
    }
    
    func getInfo(indexPath:IndexPath)->ReportModel? {
        switch indexPath.section {
        case 0:
            return users[indexPath.row]
        case 1:
            return talks[indexPath.row]
        case 2:
            return reviews[indexPath.row]
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch indexPath.section {
        case 3:
            let info = blockedUsers[indexPath.row]
            cell.textLabel?.text = info.email
            cell.detailTextLabel?.text = info.name
        default:
            if let info = getInfo(indexPath: indexPath) {
                cell.textLabel?.text = info.reporter?.name
                cell.detailTextLabel?.text = info.desc
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return users.count > 0 ? "부적적한 유저 신고" : nil
        case 1:
            return talks.count > 0 ? "부적적한 이야기 신고" : nil
        case 2:
            return reviews.count > 0 ? "부적적한 리뷰 신고" : nil
        case 3:
            return blockedUsers.count > 0 ? "글쓰기 차단된 유저 목록" : nil
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:
            let info = blockedUsers[indexPath.row]
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "정보 보기", style: .default, handler: { (_) in
                let vc = StatusViewController.viewController(withUserId: info.id)
                self.present(vc, animated: true, completion: nil)
            }))
            ac.addAction(UIAlertAction(title: "차단 해제", style: .default, handler: { (_) in
                info.blockPostingUser(isBlock: false) { (isSucess) in
                    self.tableView.reloadData()
                }
            }))
            ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        default:
            let info = getInfo(indexPath: indexPath)
            performSegue(withIdentifier: "showDetail", sender: info?.id)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "showDetail":
            if let id = sender as? String {
                (segue.destination as? ReportDetailViewController)?.reportId = id
            }
        default:
            break
        }
    }
    
}

