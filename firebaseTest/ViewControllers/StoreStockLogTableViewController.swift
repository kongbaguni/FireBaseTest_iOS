//
//  StoreStockLogTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift

class StoreStockLogTableViewController: UITableViewController {
    var code:String? = nil
    var logs:Results<StoreStockLogModel>? {
        if let c = code {
            let d = Date(timeIntervalSince1970: (Date().timeIntervalSince1970 - 86400))
            return try! Realm().objects(StoreStockLogModel.self).filter("code = %@",c)
                .filter("regDt > %@",d)
                .sorted(byKeyPath: "regDt", ascending: true)
            
        }
        return nil
    }
    var store:StoreModel? {
        if let c = code {
            return try! Realm().object(ofType: StoreModel.self, forPrimaryKey: c)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = store?.name
        self.store?.getStoreStockLogs(complete: { (count) in
            self.tableView.reloadData()
        })
        self.refreshControl?.addTarget(self, action: #selector(self.onRefreshControl(_:)), for: .valueChanged)
    }
    
    @objc func onRefreshControl(_ sender: UIRefreshControl) {
        self.store?.getStoreStockLogs(complete: { [weak self](count) in
            sender.endRefreshing()
            self?.tableView.reloadData()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return logs?.count ?? 0
        default:
            return 0
        
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = store?.addr
            case 1:
                cell.textLabel?.text = "stockTable_desc".localized
                cell.textLabel?.textColor = .weak_text_color
                cell.textLabel?.font = UIFont.systemFont(ofSize: 10)
            default:
                break
            }
            return cell
        case 1:
            guard let log = logs?[indexPath.row] else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = log.remain_stat.localized
            cell.backgroundColor = StoreModel.RemainType(rawValue: log.remain_stat)?.colorValue
            cell.detailTextLabel?.text = log.regDt.simpleFormatStringValue
            return cell
        default:
            return UITableViewCell()
        }
    }
        
}
