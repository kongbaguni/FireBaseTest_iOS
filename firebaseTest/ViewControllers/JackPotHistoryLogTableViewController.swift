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
        title = "JackPot Logs".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close".localized, style: .plain, target: self, action: #selector(self.onTouchupCloseBtn(_:)))
    }
    
    @objc func onTouchupCloseBtn(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
        let text = NSMutableAttributedString()
        
        text.append(NSAttributedString(string: log.regDt.relativeTimeStringValue, attributes: [
            .foregroundColor : UIColor.autoColor_switch_color,
            .font : UIFont.systemFont(ofSize: 10)
        ]))
        text.append(NSAttributedString(string: " "))

        text.append(NSAttributedString(string: log.user?.name ?? "", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.autoColor_bold_text_color]))
        cell.detailTextLabel?.attributedText = text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let log = logs[indexPath.row]
        let vc = StatusViewController.viewController
        vc.userId = log.userId
        present(vc, animated: true, completion: nil)
    }
}
