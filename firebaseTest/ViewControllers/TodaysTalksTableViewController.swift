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
import RxSwift
import RxCocoa
import FirebaseAuth

class TodaysTalksTableViewController: UITableViewController {
    var filterText:String? = nil
    var list:Results<TalkModel> {
        var result = try! Realm().objects(TalkModel.self)
            .sorted(byKeyPath: "regTimeIntervalSince1970", ascending: true)
            .filter("regTimeIntervalSince1970 > %@", Date().timeIntervalSince1970 - Consts.LIMIT_TALK_TIME_INTERVAL)
        
        if let txt = filterText {
            result = result.filter("textForSearch CONTAINS[c] %@", txt)
        }
        
        return result
    }
    let disposebag = DisposeBag()
    
    var isNeedScrollToBottomWhenRefresh = false
    var needScrolIndex:IndexPath? = nil
    
    @IBOutlet weak var toolBar:UIToolbar!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "todays talks".localized
        searchBar.placeholder = "text search".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupAddBtn(_:)))
        refreshControl?.addTarget(self, action: #selector(self.onRefreshControl(_:)), for: .valueChanged)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        searchBar
            .rx.text
            .orEmpty
            .subscribe(onNext: { [weak self](query) in
                print(query)
                let q = query.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                if q.isEmpty == false {
                    self?.filterText = q
                } else {
                    self?.filterText = nil
                }
                self?.tableView.reloadData()
            }).disposed(by: self.disposebag)
        
        toolBar.items = [
            UIBarButtonItem(title: "write talk".localized, style: .plain, target: self, action: #selector(self.onTouchupAddBtn(_:)))
        ]
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
        case "showDetail":
            if let id = sender as? String,
                let vc = segue.destination as? TalkDetailTableViewController {
                vc.documentId = id
            }
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc func onRefreshControl(_ sender:UIRefreshControl) {
        let oldCount = self.tableView.numberOfRows(inSection: 0)
        UserInfo.info?.syncData(complete: { (_) in
            TalkModel.syncDatas {
                sender.endRefreshing()
                self.tableView.reloadData()
                if self.isNeedScrollToBottomWhenRefresh {
                    let number = self.tableView.numberOfRows(inSection: 0)
                    if oldCount != number {
                        self.tableView.scrollToRow(at: IndexPath(row: number - 1, section: 0), at: .middle, animated: true)
                    }
                    self.isNeedScrollToBottomWhenRefresh = false
                }
                if let index = self.needScrolIndex {
                    self.tableView.scrollToRow(at: index, at: .middle, animated: true)
                    self.needScrolIndex = nil
                }
            }
        })

    }
    
    @objc func onTouchupAddBtn(_ sender:UIBarButtonItem) {
        
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "myProfile".localized, style: .default, handler: { (action) in
            self.navigationController?.performSegue(withIdentifier: "showMyProfile", sender: nil)
        }))
        
        vc.addAction(UIAlertAction(title: "write talk".localized, style: .default, handler: { (action) in
            self.isNeedScrollToBottomWhenRefresh = true
            self.performSegue(withIdentifier: "showTalk", sender: nil)
        }))

        vc.addAction(UIAlertAction(title: "logout".localized, style: .default, handler: { (action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
                return
            }
            
            UserInfo.info?.logout()
        }))
        
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = list[indexPath.row]
        
        let cellId = data.creatorId == UserInfo.info?.id ? "myCell" : "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodayTalksTableViewCell
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
        action.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.15, alpha: 1)
        let iconRed =  #imageLiteral(resourceName: "heart").af_imageAspectScaled(toFit: CGSize(width: 20, height: 20))
                      
        let iconWhite =  iconRed.withTintColor(.white)
        action.image = model.isLike ? iconRed : iconWhite
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let data = list[indexPath.row]
        var actions:[UIContextualAction] = []
        if data.creatorId == UserInfo.info?.id {
            let action = UIContextualAction(style: .normal, title: "edit".localized, handler: { [weak self](action, view, complete) in
                if let data = self?.list[indexPath.row] {
                    self?.needScrolIndex = indexPath
                    self?.performSegue(withIdentifier: "showTalk", sender: data.id)
                }
            })
            action.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1)
            actions.append(
                action
            )
        }
        let detailAction = UIContextualAction(style: .normal, title: "detail View".localized, handler: { [weak self] (action, view, complete)  in
            if let talk = self?.list[indexPath.row] {
                self?.performSegue(withIdentifier: "showDetail", sender: talk.id)
            }
        })
        detailAction.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.6, alpha: 1)
        actions.append(detailAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
 
}

