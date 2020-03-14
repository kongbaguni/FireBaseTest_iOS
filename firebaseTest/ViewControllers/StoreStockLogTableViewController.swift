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
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let log = logs?[indexPath.row] else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = log.remain_stat.localized
        cell.backgroundColor = StoreModel.RemainType(rawValue: log.remain_stat)?.colorValue
        cell.detailTextLabel?.text = log.regDt.simpleFormatStringValue
        return cell        
    }
    
}
