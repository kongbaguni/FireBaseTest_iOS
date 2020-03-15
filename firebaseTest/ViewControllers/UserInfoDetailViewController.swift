//
//  UserInfoDetailViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher
import RealmSwift
import GoogleMobileAds

class UserInfoDetailViewController: UITableViewController {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var intoduceLabel:UILabel!
    @IBOutlet weak var pointTitleLabel:UILabel!
    @IBOutlet weak var pointLabel:UILabel!
    @IBOutlet weak var pointCell:UITableViewCell!
    @IBOutlet weak var levelTitleLabel:UILabel!
    @IBOutlet weak var levelLabel:UILabel!
    @IBOutlet weak var expTitleLabel:UILabel!
    @IBOutlet weak var expLabel:UILabel!
    
    var userId:String? = nil
    var user:UserInfo? {
        if let id = userId {
            return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: id)
        }
        return nil
    }
    
    let googlead = GoogleAd()
    class var viewController : UserInfoDetailViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "userInfoDetail") as! UserInfoDetailViewController
        
    }
 
    deinit {
        debugPrint("deinit \(#file)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = user?.name
        pointTitleLabel.text = "Point".localized
        levelTitleLabel.text = "level".localized
        expTitleLabel.text = "exp".localized
        
        pointLabel.text = "\(user?.point ?? 0)"
        loadData()
        
        if user?.id == UserInfo.info?.id {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.onTouchupRightBarButton(_:)))
            emailCell.selectionStyle = .none
            pointCell.selectionStyle = .default
        }
    }
    
    @objc func onTouchupRightBarButton(_ sender:UIBarButtonItem) {
        performSegue(withIdentifier: "profileEdit", sender: nil)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
        
    func loadData() {
        profileImageView.kf.setImage(with: user?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = user?.name
        emailLabel.text = user?.email
        intoduceLabel.text = user?.introduce
        pointLabel.text = user?.point.decimalForamtString
        levelLabel.text = user?.levelStrValue
        expLabel.text = user?.exp.decimalForamtString
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        switch cell?.reuseIdentifier {
        case "profileImage":
            let vc = StatusViewController.viewController
            vc.userId = self.userId
            present(vc, animated: true, completion: nil)
        case "email":
            if cell?.textLabel?.text == UserInfo.info?.email {
                return
            }
            let msg = String(format:"Send an email to %@".localized, user?.name ?? "")
            let vc = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (_) in
                if let txt = cell?.textLabel?.text {
                    if let url = URL(string: "mailto:\(txt)") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }))
            vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            present(vc, animated: true, completion: nil)
        case "point":
            googlead.showAd(targetViewController: self) { (isSucess) in
                if isSucess {
                    GameManager.shared.addPoint(point: Consts.POINT_BY_AD) { (isSucess) in
                        if isSucess {
                            let msg = String(format:"%@ point get!".localized, Consts.POINT_BY_AD.decimalForamtString)
                            Toast.makeToast(message: msg)
                            self.loadData()
                        }
                    }
                }
            }

        default:
            break
        }
    }
    
}

