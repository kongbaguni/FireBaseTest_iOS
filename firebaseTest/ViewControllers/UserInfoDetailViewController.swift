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

class UserInfoDetailViewController: UITableViewController {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var intoduceLabel:UILabel!
    @IBOutlet weak var profileUpdateDtTitleLabel:UILabel!
    @IBOutlet weak var profileUpdateDtLabel:UILabel!
    @IBOutlet weak var lastTalkDtTitleLabel:UILabel!
    @IBOutlet weak var lastTalkDtLabel:UILabel!
    var userId:String? = nil
    var user:UserInfo? {
        if let id = userId {
            return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: id)
        }
        return nil
    }
    
    class var viewController : UserInfoDetailViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "userInfoDetail") as! UserInfoDetailViewController
        
    }
 
    deinit {
        debugPrint("deinit \(#file)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = user?.name
        profileUpdateDtTitleLabel.text = "last update profile".localized;
        lastTalkDtTitleLabel.text = "last talk date".localized
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
        
    func loadData() {
        profileImageView.kf.setImage(with: user?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = user?.name
        intoduceLabel.text = user?.introduce
        profileUpdateDtLabel.text = user?.updateDt.distanceStringValue
        lastTalkDtLabel.text = user?.lastTalkDt?.distanceStringValue ?? "none".localized
//        userInfo?.syncData { isNew in
//            self.profileImageView.kf.setImage(with: userInfo?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
//            self.nameLabel.text = userInfo?.name
//            self.intoduceLabel.text = userInfo?.introduce
//        }
    }
    
    
}
