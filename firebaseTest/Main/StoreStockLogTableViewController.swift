//
//  StoreStockLogTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class StoreStockLogTableViewController: UITableViewController {
    var code:String? = nil

    let disposeBag = DisposeBag()
    @IBOutlet weak var footerBtn: UIButton!
    var logs:Results<StoreStockLogModel>? {
        if let c = code {
            return try! Realm().objects(StoreStockLogModel.self)
            .filter("code = %@",c)
            .sorted(byKeyPath: "regDtTimeIntervalSince1970", ascending: false)
        }
        return nil
    }
    
    var todayLogs:Results<StoreStockLogModel>? {
        return logs?.filter("regDtTimeIntervalSince1970 >= %@",Date.midnightTodayTime.timeIntervalSince1970)
    }
    
    func getList(dayBefore:Int)->Results<StoreStockLogModel>? {
        if dayBefore == 0 {
            return todayLogs
        }
        let d1 = Date.getMidnightTime(beforDay: dayBefore - 1).timeIntervalSince1970
        let d2 = Date.getMidnightTime(beforDay: dayBefore).timeIntervalSince1970
        return logs?.filter("regDtTimeIntervalSince1970 < %@ && regDtTimeIntervalSince1970 >= %@", d1, d2)
    }
    
    var store:StoreModel? {
        if let c = code {
            return try! Realm().object(ofType: StoreModel.self, forPrimaryKey: c)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "show stock log".localized
        navigationItem.prompt = store?.name
        self.refreshControl?.addTarget(self, action: #selector(self.onRefreshControl(_:)), for: .valueChanged)
        onRefreshControl(UIRefreshControl())
        footerBtn.setTitle("show waitting log".localized, for: .normal)
        footerBtn.rx.tap.bind { [weak self](_) in
            self?.performSegue(withIdentifier: "showWaitting", sender: nil)
        }.disposed(by: self.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showWaitting":
            if let vc = segue.destination as? StoreWaittingTableViewController {
                vc.storeId = self.store?.code
            }
        default:
            break
        }
    }
    
    func uploadLogIfNeed(complete:@escaping(_ isSucess:Bool)->Void) {
        guard let store = self.store else {
            complete(false)
            return
        }
        guard let userInfo = UserInfo.info else {
            complete(false)
            return
        }

        if todayLogs?.first?.remain_stat != store.remain_stat || todayLogs?.count == 0 {
            let data:[String:Any] = [
                "email" : userInfo.email,
                "exp": userInfo.exp + AdminOptions.shared.expForReportStoreStock,
                "point" : userInfo.point + AdminOptions.shared.pointForReportStoreStock,
                "lastTalkTimeIntervalSince1970" : Date().timeIntervalSince1970,
                "count_of_report_stock" : userInfo.count_of_report_stock + 1
            ]
            
            StoreStockLogModel.uploadStoreStocks(code: store.code, remain_stat: store.remain_stat) { [weak self](sucess) in
                if sucess {
                    userInfo.update(data: data) { (sucess) in
                        if sucess {
                            let vc = StatusViewController.viewController(withUserId: userInfo.id)
                            vc.statusChange = StatusChange(addedExp: AdminOptions.shared.expForReportStoreStock, pointChange: AdminOptions.shared.pointForReportStoreStock)
                            self?.present(vc, animated: true, completion: nil)
                        }
                        complete(sucess)
                    }
                }
            }
            
        }
        complete(true)
    }
    let loading = Loading()
    @objc func onRefreshControl(_ sender: UIRefreshControl) {
        
        if sender != self.refreshControl {
            loading.show(viewController: self)
        }
        self.store?.getStoreStockLogs(complete: { [weak self](count) in
            if let s = self {
                if sender != s.refreshControl {
                    self?.loading.hide()
                }
            }
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
                cell.textLabel?.textColor = .autoColor_weak_text_color
                cell.textLabel?.font = UIFont.systemFont(ofSize: 10)
            default:
                break
            }
            return cell
        case 1:
            guard let log = todayLogs?[indexPath.row] else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "storeLogCell", for: indexPath) as! StoreStockLogTableViewCell
            cell.stockId = log.id
            return cell
            
        default:
            guard let log = getList(dayBefore: indexPath.section-1)?[indexPath.row] else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "storeLogCell", for: indexPath) as! StoreStockLogTableViewCell
            cell.stockId = log.id
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            guard let logs = todayLogs else {
                return nil
            }
            if logs.count == 0 {
                return nil
            }
            return "today".localized
        default:
            if getList(dayBefore: section - 1)?.count == 0 {
                return nil
            }
            return String(format:"%@ days before".localized, "\(section - 1)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            break
        case 1:
            guard let log = todayLogs?[indexPath.row] else {
                return
            }
            let vc = StatusViewController.viewController(withUserId: log.uploaderId)
            present(vc, animated: true, completion: nil)
            
        default:
            guard let log = getList(dayBefore: indexPath.section-1)?[indexPath.row] else {
                return
            }
            let vc = StatusViewController.viewController(withUserId: log.uploaderId)
            present(vc, animated: true, completion: nil)
        }
    }
}
