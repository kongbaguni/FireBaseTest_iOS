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
    class var viewController : MainViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "main") as! MainViewController
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupMenuBtn(_:)))
    }
    
    @objc func onTouchupMenuBtn(_ sender:UIBarButtonItem) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "logout", style: .default, handler: { (action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
                return
            }
            UserDefaults.standard.authVerificationID = nil
            self.navigationController?.viewControllers = [PhoneAuthViewController.viewController]
        }))
        vc.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
        
    }
}
