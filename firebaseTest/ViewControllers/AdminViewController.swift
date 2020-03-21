//
//  AdminViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

class AdminViewController: UITableViewController {
    static var viewController : AdminViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "admin") as! AdminViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "admin") as! AdminViewController
            // Fallback on earlier versions
        }
    }
    
    var keys:[String] {
        return Array(AdminOptions.shared.allData.keys).sorted()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AdminOptions.shared.getData {[weak self] in
            self?.tableView.reloadData()
        }
        title = "admin menu"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = keys[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = key.localized
        let value = "\(AdminOptions.shared.allData[key] ?? "")"
        cell.detailTextLabel?.text = value
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = keys[indexPath.row]
        let vc = UIAlertController(title: "input Option", message: key.localized, preferredStyle: .alert)
        vc.addTextField { (textField) in
            textField.text = "\(AdminOptions.shared.allData[key] ?? "")"
        }
        vc.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (action) in
            guard let text = vc.textFields?.first?.text else {
                return
            }
            if AdminOptions.shared.setData(key: key, value: text) == false {
                Toast.makeToast(message: "잘못된 입력이다.")
            } else {
                AdminOptions.shared.updateData { (sucess) in
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }))
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
    
    
}
