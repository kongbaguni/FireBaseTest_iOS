//
//  StoreWaittingTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import CoreLocation
import RxCocoa
import RxSwift

class StoreWaittingTableViewController: UITableViewController {
    static var viewController:StoreWaittingTableViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "storeWaitting") as! StoreWaittingTableViewController
        } else {
            return UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "storeWaitting") as! StoreWaittingTableViewController
        }
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var postLogBtn: UIButton!
    
    let disposebag = DisposeBag()
    
    var storeId:String? = nil
    
    var store:StoreModel? {
        if let id = storeId {
            let store = try? Realm().object(ofType: StoreModel.self, forPrimaryKey: id)
            if store?.isInvalidated == true {
                return nil
            }
            return store
        }
        return nil
    }
    
    var waitingLogs:Results<StoreWaitingModel>? {
        if let id = self.storeId {
            return try? Realm().objects(StoreWaitingModel.self).filter("storeCode = %@",id).sorted(byKeyPath: "regDt", ascending: false)
        }
        return nil
    }
    
    func getLogs(beforeDay:Int)->Results<StoreWaitingModel>? {
        if var logs = waitingLogs {
            if beforeDay == 0 {
                logs = logs.filter("regDt >= %@", Date.midnightTodayTime)
            }
            else {
                let d1 = Date.getMidnightTime(beforDay: beforeDay - 1)
                let d2 = Date.getMidnightTime(beforDay: beforeDay)
                logs = logs.filter("regDt < %@ && regDt >= %@", d1, d2)
            }
            return logs
            
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#file) \(#function) \(#line)-----")
        title = store?.name
        setTitle()
        postLogBtn.isEnabled = false
        postLogBtn.setTitle("", for: .normal)
        NotificationCenter.default.addObserver(forName: .locationUpdateNotification, object: nil, queue: nil) { [weak self](notification) in
            if let l = notification.object as? [CLLocation] {
                UserDefaults.standard.lastMyCoordinate = l.first?.coordinate
            }
            self?.setTitle()
        }
        
        
        postLogBtn.rx.tap
            .bind { (_) in
                let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                
                for status in StoreWaitingModel.WaittingStatus.allCases {
                    ac.addAction(UIAlertAction(
                        title: status.rawValue.localized,
                        style: .default, handler: { (_) in
                            self.postWaitting(status: status)
                    }))
                }
                ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
        }.disposed(by: disposebag)
        
        self.refreshControl?.addTarget(self, action: #selector(self.onRefreshControl(_:)), for: .valueChanged)
        self.onRefreshControl(UIRefreshControl())
    }
        
    
    let loading = Loading()
    @objc func onRefreshControl(_ sender:UIRefreshControl) {
        if sender != self.refreshControl {
            loading.show(viewController: self)
        }
        self.store?.getStoreWaittingLogs(complete: { [weak self](count) in
            sender.endRefreshing()
            self?.loading.hide()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.shared.manager.startUpdatingLocation()
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.shared.manager.stopUpdatingHeading()
    }
    
    private func postWaitting(status:StoreWaitingModel.WaittingStatus) {
        guard let storecode = self.storeId else {
            return
        }
        let loading = Loading()
        let data = StoreWaitingModel()
        loading.show(viewController: self)
        data.creatorId = UserInfo.info?.id ?? "guest"
        data.status = status.rawValue
        data.storeCode = storecode
        data.uploadLog { [weak self](isSucess) in
            self?.store?.getStoreWaittingLogs(complete: {[weak self] (count) in
                self?.tableView.reloadData()
                loading.hide()
            })
        }
    }
    
    private func setTitle() {
        guard let mc = UserDefaults.standard.lastMyCoordinate else {
            return
        }
        if let distance = store?.getLiveDistance(coodinate: mc) {
            let value = Double(Int(distance * 100))/100
            headerLabel.text = "\("distance".localized) : \(value)m"
            postLogBtn.isEnabled = value < Double(AdminOptions.shared.waitting_report_distance)
            if UserInfo.info == nil {
                postLogBtn.isEnabled = false
            }
            postLogBtn.setTitle("waitting btn title desable".localized, for: .normal)

//            if postLogBtn.isEnabled {
//            } else {
//                let title = String(format:"waitting btn title enable %@".localized, Consts.WAITING_REPORT_DISTANCE.decimalForamtString)
//                postLogBtn.setTitle(title, for: .normal)
//            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let count = getLogs(beforeDay: section)?.count
        if  count == 0 || count == nil {
            return nil
        }
        
        switch section {
        case 0:
            return "today".localized
        default:
            return String(format:"%@ days before".localized, "\(section)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getLogs(beforeDay: section)?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let log = getLogs(beforeDay: indexPath.section)?[indexPath.row] else {
            return UITableViewCell()
        }
        let id = log.creatorId == UserInfo.info?.id ? "myCell" : "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! WaittingLogTableViewCell
        cell.logid = log.id
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let log = getLogs(beforeDay: indexPath.section)?[indexPath.row] else {
            return
        }
        let vc = StatusViewController.viewController
        vc.userId = log.creatorId
        present(vc, animated: true, completion: nil)
    }
}


