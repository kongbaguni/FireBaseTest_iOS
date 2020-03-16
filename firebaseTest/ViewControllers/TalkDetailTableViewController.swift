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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "detail View".localized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if talkModel?.cordinate != nil {
            return 4
        }
        return 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showUserInfoDetail":
            if
            let id = sender as? String,
                let vc = segue.destination as? UserInfoDetailViewController {
                vc.userId = id
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return (talkModel?.editList.count ?? 0) + 1
        case 2:
            return talkModel?.likes.count ?? 0
        case 3:
            return 1
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
            if talkModel?.bettingPoint ?? 0 > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cardDack", for: indexPath) as! TalkDetailCardDackTavleViewCell
                cell.talkId = talkModel?.id
                return cell
            }
            if let editList = talkModel?.editList {
                if indexPath.row == 0 {
                    if let imgUrl = talkModel?.imageUrl {
                        if imgUrl.isEmpty == false {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "editHistoryImage") as! TalkDetailEditHistoryImageTableViewCell
                            cell.dateLabel.text = talkModel?.regDt.simpleFormatStringValue
                            cell.textView.text = talkModel?.text
                            cell.attachmentImageView.setImageUrl(url: imgUrl, placeHolder: #imageLiteral(resourceName: "placeholder"))
                            return cell
                        }
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: "editHistory") as! TalkDetailEditHistoryTableViewCell
                    cell.dateLabel.text = talkModel?.regDt.simpleFormatStringValue
                    cell.textView.text = talkModel?.text
                    return cell
                }
                let data = editList[indexPath.row - 1]
                if data.imageUrl != nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "editHistoryImage") as! TalkDetailEditHistoryImageTableViewCell
                    cell.setData(data: data)
                    return cell

                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "editHistory") as! TalkDetailEditHistoryTableViewCell
                    cell.setData(data: data)
                    return cell
                }
            }
            return UITableViewCell()
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo") as! TalkDetailUserInfoTableViewCell
            if let likeList = talkModel?.likes {
                cell.setData(like: likeList[indexPath.row])
            }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "map") as! TalkDetailMapTableViewCell
            cell.location = talkModel?.location
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "creator".localized
        case 1:
            if talkModel?.bettingPoint ?? 0 > 0 {
                return "game result".localized
            }
            return "edit history".localized
        case 2:
            if talkModel?.likes.count == 0 {
                return nil
            }
            return "like peoples".localized
        case 3:
            return "posting location".localized
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = StatusViewController.viewController
            vc.userId = self.talkModel?.creatorId
            present(vc, animated: true, completion: nil)
//            performSegue(withIdentifier: "showUserInfoDetail", sender: self.talkModel?.creatorId)
        case 2:
            if let likes = talkModel?.likes {
                let id = likes[indexPath.row].creator?.id
                let vc = StatusViewController.viewController
                vc.userId = id
                present(vc, animated: true, completion: nil)
            }
        default:
            break
        }
    }

}
