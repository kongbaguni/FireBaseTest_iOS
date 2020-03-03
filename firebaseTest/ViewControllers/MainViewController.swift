//
//  MainViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupMenuBtn(_:)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
        
    func loadData() {
        let userInfo = UserDefaults.standard.userInfo
        
        profileImageView.setImage(image: userInfo?.profileImage, placeHolder: #imageLiteral(resourceName: "profile"))
        nameLabel.text = userInfo?.name
        intoduceLabel.text = userInfo?.introduce
        userInfo?.syncData {
            self.profileImageView.setImage(image: UserDefaults.standard.userInfo?.profileImage, placeHolder: #imageLiteral(resourceName: "profile"))
            self.nameLabel.text = userInfo?.name
            self.intoduceLabel.text = userInfo?.introduce
        }
    }
    
    @objc func onTouchupMenuBtn(_ sender:UIBarButtonItem) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "myProfile", style: .default, handler: { (action) in
            self.navigationController?.performSegue(withIdentifier: "showMyProfile", sender: nil)
        }))
        
        vc.addAction(UIAlertAction(title: "logout", style: .default, handler: { (action) in
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
        
        vc.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
        
    }
}
