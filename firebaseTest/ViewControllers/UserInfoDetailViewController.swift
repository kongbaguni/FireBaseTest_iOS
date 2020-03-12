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
    @IBOutlet weak var pointTitleLabel:UILabel!
    @IBOutlet weak var pointLabel:UILabel!
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
        pointTitleLabel.text = "Point".localized
        pointLabel.text = "\(user?.point ?? 0)"
        loadData()
        
        if user?.id == UserInfo.info?.id {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupRightBarButton(_:)))
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
        intoduceLabel.text = user?.introduce
        pointLabel.text = user?.point.decimalForamtString
    }
    
    
}
