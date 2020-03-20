//
//  UserListTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth
import RxCocoa
import RxSwift

class UserListTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filterText:String? = nil
    let disposebag = DisposeBag()
    
    var users:Results<UserInfo> {
        var result = try! Realm().objects(UserInfo.self).sorted(byKeyPath: "updateDt")
        
        if let text = filterText {
            result = result.filter("name CONTAINS[c] %@", text)
        } else {
            result = result.filter("email != %@",UserInfo.info!.email)
        }
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "users list".localized
        searchBar.placeholder = "name search".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupMenuBtn(_:)))
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension

        refreshControl?.addTarget(self, action: #selector(self.onRefreshControll(_:)), for: .valueChanged)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showUserInfoDetail":
            if let vc = segue.destination as? UserInfoDetailViewController ,
                let id = sender as? String {
                vc.userId = id
            }
        default:
            break
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if filterText != nil {
                return 0
            }
            return 1
        case 1:
            return users.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo") as! TalkDetailUserInfoTableViewCell
        switch indexPath.section {
        case 0:
            cell.userId = UserInfo.info!.id
        case 1:
            cell.userId = users[indexPath.row].id
        default:
            break
        }
        return cell
    }
    
    @objc func onRefreshControll(_ sender:UIRefreshControl) {
        UserInfo.info?.syncData(complete: { [weak self](sucess) in
            self?.tableView.reloadData()
            sender.endRefreshing()
        })
    }
    
    @objc func onTouchupMenuBtn(_ sender:UIBarButtonItem) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "myProfile".localized, style: .default, handler: { (action) in
            self.navigationController?.performSegue(withIdentifier: "showMyProfile", sender: nil)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showUserInfoDetail", sender: UserInfo.info!.id)
        case 1:
            let id = users[indexPath.row].id
            performSegue(withIdentifier: "showUserInfoDetail", sender: id)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
