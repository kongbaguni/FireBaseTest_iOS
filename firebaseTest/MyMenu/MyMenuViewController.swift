//
//  MyMenuViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/07/01.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

class MyMenuViewController: UITableViewController {
    enum CellType {
        /** 프로필*/
        case profile
        /** 로그아웃 */
        case logout
        /** 관리자 메뉴*/
        case adminMenu
        /** 신고목록*/
        case reportList
        /** 내가 작성한 글 목록*/
        case myArticles
        /** 앱 정보*/
        case appinfo
        /** 구독하기*/
        case subscribe
        /** 공지 목록*/
        case noticeList
        /** 빈칸*/
        case blank
    }
    var cellTypes:[[CellType]] {
        var list:[[CellType]] = [
            [
                .profile,
                .myArticles,
                .logout
            ],
            [
                .subscribe,
                .appinfo
            ],
            [
                .noticeList,
            ]
        ]
        if Consts.isAdmin {
            list.append([
                .adminMenu,
                .reportList,
            ])
        }
        return list
    }
    
    static var viewController : MyMenuViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "MyMenu", bundle: nil).instantiateViewController(identifier: "root")
        } else {
            return UIStoryboard(name: "MyMenu", bundle: nil).instantiateViewController(withIdentifier: "root") as! MyMenuViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu".localized
        NotificationCenter.default.addObserver(forName: .profileUpdateNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellTypes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes[section].count
    }
    
    func getType(indexPath:IndexPath)->CellType? {
        return cellTypes[indexPath.section][indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch getType(indexPath: indexPath) {
        case .profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profile", for: indexPath) as! ProfileTableViewCell
            cell.profileImageView.kf.setImage(with: UserInfo.info?.profileImageURL, placeholder: UIImage.placeHolder_profile)
            cell.nameLabel.text = UserInfo.info?.name
            cell.emailLabel.text = UserInfo.info?.email
            return cell
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        switch getType(indexPath: indexPath) {
        case .logout:
            cell.textLabel?.text = "logout".localized
            cell.accessoryType = .none
            return cell
        case .adminMenu:
            cell.textLabel?.text = "admin menu".localized
            return cell
        case .reportList:
            cell.textLabel?.text = "report list".localized
        case .appinfo:
            cell.textLabel?.text = "appInfo".localized
        case .myArticles:
            cell.textLabel?.text = "talk logs".localized
        case .subscribe:
            cell.textLabel?.text = "in app Purchase title".localized
        case .noticeList:
            cell.textLabel?.text = "notice".localized
        case .blank:
            cell.textLabel?.text = nil
            cell.accessoryType = .none
            cell.selectionStyle = .none
        default:
            break
        }
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch getType(indexPath: indexPath) {
        case .profile:
            let vc = MyProfileViewController.viewController
            self.navigationController?.pushViewController(vc, animated: true)
        case .logout:
            UserInfo.info?.logout()
        case .adminMenu:
            let vc = AdminViewController.viewController
            self.navigationController?.pushViewController(vc, animated: true)
        case .reportList:
            let vc = ReportListViewController.viewController
            self.navigationController?.pushViewController(vc, animated: true)
        case .myArticles:
            let vc = TalkHistoryTableViewController.viewController
            vc.userId = UserInfo.info?.id
            self.navigationController?.pushViewController(vc, animated: true)
        case .subscribe:
            let vc = InAppPurchesTableViewController.viewController
            self.present(vc, animated: true, completion: nil)
        case .noticeList:
            let vc = NoticeListViewController.viewController
            self.navigationController?.pushViewController(vc, animated: true)
        case .appinfo:
            performSegue(withIdentifier: "showAppInfo", sender: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
}

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var emailLabel:UILabel!
}
