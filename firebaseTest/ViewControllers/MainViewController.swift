//
//  MainViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

class MainViewController: UIViewController {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var intoduceLabel:UILabel!
    
    class var viewController : MainViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "main") as! MainViewController
    }
 
    deinit {
        debugPrint("deinit \(#file)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "home"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupMenuBtn(_:)))
        if UserDefaults.standard.userInfo?.name?.isEmpty == true {
            navigationController?.performSegue(withIdentifier: "showMyProfile", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
        
    func loadData() {
        let userInfo = UserDefaults.standard.userInfo
        profileImageView.image = #imageLiteral(resourceName: "profile")
        profileImageView.setImageUrl(url: userInfo?.profileImageURL, placeHolder: #imageLiteral(resourceName: "profile"))
        
        nameLabel.text = userInfo?.name
        intoduceLabel.text = userInfo?.introduce
        userInfo?.syncData {
            
            self.profileImageView.setImageUrl(url: userInfo?.profileImageURL, placeHolder: #imageLiteral(resourceName: "profile"))
            self.nameLabel.text = userInfo?.name
            self.intoduceLabel.text = userInfo?.introduce
        }
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
            UserDefaults.standard.userInfo = nil
            self.navigationController?.viewControllers = [PhoneAuthViewController.viewController]
        }))
        
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
        
    }
}
