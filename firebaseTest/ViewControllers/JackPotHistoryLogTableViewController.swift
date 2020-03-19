//
//  JackPotHistoryLogTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
class JackPotHistoryLogTableViewController: UITableViewController {
    var logs:Results<JackPotLogModel> {
        try! Realm().objects(JackPotLogModel.self).sorted(byKeyPath: "regTimeIntervalSince1970", ascending: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        JackPotManager.shared.getJackPotHistoryLog { (sucess) in
            if sucess {
                self.tableView.reloadData()
            }
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let log = logs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = log.point.decimalForamtString
        cell.detailTextLabel?.text = log.user?.name
        return cell
    }
}
