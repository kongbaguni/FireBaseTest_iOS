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
import RealmSwift

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
        if UserInfo.info?.name.isEmpty == true {
            navigationController?.performSegue(withIdentifier: "showMyProfile", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
        
    func loadData() {
        let userInfo = UserInfo.info
        profileImageView.image = #imageLiteral(resourceName: "profile")
        profileImageView.kf.setImage(with: userInfo?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        
        nameLabel.text = userInfo?.name
        intoduceLabel.text = userInfo?.introduce
        userInfo?.syncData {
            self.profileImageView.kf.setImage(with: userInfo?.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
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
            //TODO: LOGOUT DB clear
            do {
                let realm = try Realm()
                realm.beginWrite()
                realm.delete(realm.objects(UserInfo.self))
                try realm.commitWrite()
            } catch {
                debugPrint(error.localizedDescription)
                return
            }
            UIApplication.shared.windows.first?.rootViewController = LoginViewController.viewController
        }))
        
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
        
    }
}
