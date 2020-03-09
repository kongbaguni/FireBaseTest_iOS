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
import AlamofireImage

class TodaysTalksTableViewController: UITableViewController {
    var list:Results<TalkModel> {
        return try! Realm().objects(TalkModel.self).sorted(byKeyPath: "regTimeIntervalSince1970", ascending: false).filter("regTimeIntervalSince1970 > %@", Date().timeIntervalSince1970 - Consts.LIMIT_TALK_TIME_INTERVAL)
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
        self.onRefreshControl(UIRefreshControl())
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
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let model = list[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "like", handler: { (action, view, complete) in
            model.toggleLike()
            model.update { (sucess) in
                complete(true)
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        })
        
        let iconRed =  #imageLiteral(resourceName: "heart").af_imageAspectScaled(toFit: CGSize(width: 20, height: 20))
                      
        let iconWhite =  iconRed.withTintColor(.white)
        action.image = model.isLike ? iconRed : iconWhite
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let data = list[indexPath.row]
        var actions:[UIContextualAction] = []
        if data.creatorId == UserInfo.info?.id {
            actions.append(
                UIContextualAction(style: .normal, title: "edit", handler: { [weak self](action, view, complete) in
                    if let data = self?.list[indexPath.row] {
                        self?.performSegue(withIdentifier: "showTalk", sender: data.id)
                    }
                })
            )
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
 
}

