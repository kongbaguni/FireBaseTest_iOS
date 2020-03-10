//
//  TalkDetailTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
class TalkDetailTableViewController: UITableViewController {
    var documentId:String? = nil
    
    var talkModel:TalkModel? {
        if let id = documentId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return (talkModel?.editList.count ?? 0) + 1
        case 2:
            return talkModel?.likes.count ?? 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo") as! TalkDetailUserInfoTableViewCell
            if let userInfo = talkModel?.creator {
                cell.setData(info: userInfo)
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "editHistory") as! TalkDetailEditHistoryTableViewCell
            if let editList = talkModel?.editList {
                if indexPath.row == 0 {
                    cell.dateLabel.text = talkModel?.regDtStr
                    cell.textView.text = talkModel?.text
                } else {
                    let edit = editList[indexPath.row - 1]
                    cell.setData(data: edit)
                }
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo") as! TalkDetailUserInfoTableViewCell
            if let likeList = talkModel?.likes {
                if let likeUser = likeList[indexPath.row].creator {
                    cell.setData(info: likeUser)
                }
            }
            
            return cell
        default:
            abort()
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "creator".localized
        case 1:
            return "edit history".localized
        case 2:
            if talkModel?.likes.count == 0 {
                return nil
            }
            return "like peoples".localized
        default:
            return nil
        }
    }

}
