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
            return try! Realm().objects(StoreStockLogModel.self)
            .filter("code = %@",c)
            .sorted(byKeyPath: "regDt", ascending: false)
        }
        return nil
    }
    
    var todayLogs:Results<StoreStockLogModel>? {
        return logs?.filter("regDt > %@",Date.midnightTodayTime)
    }
    
    func getList(dayBefore:Int)->Results<StoreStockLogModel>? {
        if dayBefore == 0 {
            return todayLogs
        }
        let d1 = Date.getMidnightTime(beforDay: dayBefore - 1)
        let d2 = Date.getMidnightTime(beforDay: dayBefore)
        return logs?.filter("regDt < %@ && regDt >= %@", d1, d2)
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
        self.refreshControl?.addTarget(self, action: #selector(self.onRefreshControl(_:)), for: .valueChanged)
        onRefreshControl(UIRefreshControl())
    }
    
    func uploadLogIfNeed(complete:@escaping(_ isSucess:Bool)->Void) {
        guard let store = self.store else {
            return
        }
        if logs?.first?.remain_stat != store.remain_stat {
            let model = StoreStockLogModel()
            model.code = store.code
            model.remain_stat = store.remain_stat
            model.regDt = store.updateDt
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(model, update: .all)
            try!realm.commitWrite()
            model.uploadStoreStocks { (sucess) in
                complete(sucess)
            }
            return
        }
        complete(true)
    }
    
    @objc func onRefreshControl(_ sender: UIRefreshControl) {
        self.store?.getStoreStockLogs(complete: { [weak self](count) in
            self?.uploadLogIfNeed { (isSucess) in
                sender.endRefreshing()
                self?.tableView.reloadData()
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return todayLogs?.count ?? 0
        default:
            return getList(dayBefore: section - 1)?.count ?? 0
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
            guard let log = todayLogs?[indexPath.row] else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = log.remain_stat.localized
            cell.backgroundColor = StoreModel.RemainType(rawValue: log.remain_stat)?.colorValue
            cell.detailTextLabel?.text = log.regDt.formatedString(format: "M d a hh:mm:ss")
            return cell
        default:
            guard let log = getList(dayBefore: indexPath.section-1)?[indexPath.row] else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = log.remain_stat.localized
            cell.backgroundColor = StoreModel.RemainType(rawValue: log.remain_stat)?.colorValue
            cell.detailTextLabel?.text = log.regDt.formatedString(format: "M d a hh:mm:ss")
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "today".localized
        default:
            if getList(dayBefore: section - 1)?.count == 0 {
                return nil
            }
            return String(format:"%@ days before".localized, "\(section - 1)")
        }
    }
}
