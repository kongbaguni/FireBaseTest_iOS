//
//  RankingTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/25.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxCocoa
import RxSwift
import FirebaseAuth

class RankingTableViewController: UITableViewController {
    @IBOutlet weak var rankingTypeTitleLabel: UILabel!
    @IBOutlet weak var rankingTypeTextField: UITextField!
    
    static var viewController : RankingTableViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ranking") as! RankingTableViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ranking") as! RankingTableViewController
        }
    }
    
    var rankingType:UserInfo.RankingType = UserDefaults.standard.lastTypeOfRanking ?? .exp {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.rankingTypeTextField.text = self?.rankingType.rawValue.localized
                self?.tableView.reloadData()
            }
        }
    }
    
    var rankingTypes:[UserInfo.RankingType] {
        if AdminOptions.shared.canPlayPoker {
            return UserInfo.RankingType.allCases
        }
        return UserInfo.RankingType.withOutGameValues
    }
    
    var users:Results<UserInfo> {
        var result = try! Realm().objects(UserInfo.self).filter("email != %@","").sorted(byKeyPath: rankingType.rawValue, ascending: false)
        if let txt = filterText {
            result = result.filter("name CONTAINS[c] %@",txt)
        }
        return result
    }
    
    var filterText:String? = nil
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return users.count > 0 ? 1 : 0
    }
    
    let rankingTypePikcer = UIPickerView()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ranking".localized
        rankingTypeTextField.inputView = rankingTypePikcer
        rankingTypePikcer.delegate = self
        rankingTypePikcer.dataSource = self
        rankingTypeTextField.text = rankingType.rawValue.localized
        
        if let index = rankingTypes.lastIndex(of: self.rankingType) {
            rankingTypePikcer.selectRow(index, inComponent: 0, animated: false)
        } else {
            rankingTypePikcer.selectRow(0, inComponent: 0, animated: false)
            rankingType = rankingTypes[0]
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupMenuBtn(_:)))
        
        refreshControl?.addTarget(self, action: #selector(self.onRefreshControll(_:)), for: .valueChanged)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let userId = user.id
        let index = (users.lastIndex(of: user) ?? 0) + 1
        print(user)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RankingTableViewCell
        cell.setData(userId: userId, rankingType: self.rankingType)
        cell.rankingLabel.text = index.decimalForamtString
        if index <= 3 {
            cell.rankingLabel.textColor = UIColor.autoColor_bold_text_color
        } else {
            cell.rankingLabel.textColor = UIColor.autoColor_text_color
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = users[indexPath.row].id
        let vc = StatusViewController.viewController(withUserId: userId)
        present(vc, animated: true) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc func onRefreshControll(_ sender:UIRefreshControl) {
        UserInfo.syncUserInfo {[weak self] in
            sender.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
    @objc func onTouchupMenuBtn(_ sender:UIBarButtonItem) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "myProfile".localized, style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "showMyProfile", sender: nil)
        }))
        
        if Consts.isAdmin {
            vc.addAction(UIAlertAction(title: "admin menu".localized, style: .default, handler: { (action) in
                let vc = AdminViewController.viewController
                self.navigationController?.pushViewController(vc, animated: true)
            }))
        }
        
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
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true, completion: nil)
    }
}


extension RankingTableViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rankingTypes.count
    }
    
    
}

extension RankingTableViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rankingTypes[row].rawValue.localized
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.rankingType = rankingTypes[row]
        UserDefaults.standard.lastTypeOfRanking = rankingTypes[row]
    }
}
