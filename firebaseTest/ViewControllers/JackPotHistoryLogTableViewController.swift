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
    static var viewController : JackPotHistoryLogTableViewController {
        let s = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            return s.instantiateViewController(identifier: "jackPodList") as! JackPotHistoryLogTableViewController
        } else {
            return s.instantiateViewController(withIdentifier: "jackPodList") as! JackPotHistoryLogTableViewController
        }
    }
    
    var logs:Results<JackPotLogModel> {
        try! Realm().objects(JackPotLogModel.self).sorted(byKeyPath: "regTimeIntervalSince1970", ascending: false)
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
        if indexPath.row >= logs.count {
            return UITableViewCell()
        }
        let log = logs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = log.point.decimalForamtString

        let title = NSMutableAttributedString()
        title.append(NSAttributedString(string: abs(log.point).decimalForamtString, attributes: [
            .foregroundColor : log.point < 0 ? UIColor.autoColor_bold_text_color : UIColor.autoColor_weak_text_color ,
            .font : UIFont.boldSystemFont(ofSize: 15)
        ]))
        title.append(NSAttributedString(string: log.point < 0 ?  "Paid".localized :  "Earned".localized , attributes: [
            .foregroundColor : UIColor.autoColor_weak_text_color,
            .font : UIFont.systemFont(ofSize: 10)
        ]))
        cell.textLabel?.attributedText = title
        
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
        let vc = StatusViewController.viewController(withUserId: log.userId)
        present(vc, animated: true, completion: nil)
    }
}
