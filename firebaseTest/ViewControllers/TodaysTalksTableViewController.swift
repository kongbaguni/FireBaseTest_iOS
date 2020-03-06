//
//  TodaysTalksTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RealmSwift

class TodaysTalksTableViewController: UITableViewController {
    var list:Results<TalkModel> {
        return try! Realm().objects(TalkModel.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "todays talks".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupAddBtn(_:)))
        refreshControl?.addTarget(self, action: #selector(self.onRefreshControl(_:)), for: .valueChanged)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTalk":
            if let id =  sender as? String, let vc = segue.destination as? PostTalkViewController  {
                vc.documentId  = id
            }
            
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc func onRefreshControl(_ sender:UIRefreshControl) {
        TalkModel.syncDatas {
            sender.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    @objc func onTouchupAddBtn(_ sender:UIBarButtonItem) {
        performSegue(withIdentifier: "showTalk", sender: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodayTalksTableViewCell
        cell.setData(data: list[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = list[indexPath.row]
        performSegue(withIdentifier: "showTalk", sender: data.id)
    }
        
}
