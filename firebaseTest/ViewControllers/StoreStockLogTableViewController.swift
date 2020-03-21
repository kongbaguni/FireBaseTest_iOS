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
            .sorted(byKeyPath: "regDt", ascending: false)
        }
        return nil
    }
    
    var todayLogs:Results<StoreStockLogModel>? {
        return logs?.filter("regDt >= %@",Date.midnightTodayTime)
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
        footerBtn.setTitle("show waitting log".localized, for: .normal)
        footerBtn.rx.tap.bind { (_) in
            self.performSegue(withIdentifier: "showWaitting", sender: nil)
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
            return
        }
        if logs?.first?.remain_stat != store.remain_stat {
            let model = StoreStockLogModel()
            model.code = store.code
            model.remain_stat = store.remain_stat
            model.regDt = store.updateDt
            if UserInfo.info?.isAnonymousInventoryReport == true {
                model.uploaderId = "guest"
            } else {
                model.uploaderId = UserInfo.info?.id ?? "guest"
            }
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(model, update: .all)
            try!realm.commitWrite()
            model.uploadStoreStocks { (sucess) in
                complete(sucess)
            }
            UserInfo.info?.updateLastTalkTime(complete: { (sucess) in
                
            })
            return
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
            let vc = StatusViewController.viewController
            vc.userId = log.uploader?.id
            present(vc, animated: true, completion: nil)
            
        default:
            guard let log = getList(dayBefore: indexPath.section-1)?[indexPath.row] else {
                return
            }
            let vc = StatusViewController.viewController
            vc.userId = log.uploader?.id
            present(vc, animated: true, completion: nil)
        }
    }
}
