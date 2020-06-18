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

    override func viewDidLoad() {
        super.viewDidLoad()
        ReportModel.syncReports { [weak self](isSucess) in
            self?.tableView.reloadData()
        }
        title = "report list".localized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return users.count
        case 1:
            return talks.count
        case 2:
            return reviews.count
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
        if let info = getInfo(indexPath: indexPath) {
            cell.textLabel?.text = info.reporter?.name
            cell.detailTextLabel?.text = info.desc
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = getInfo(indexPath: indexPath)
        performSegue(withIdentifier: "showDetail", sender: info?.id)
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

