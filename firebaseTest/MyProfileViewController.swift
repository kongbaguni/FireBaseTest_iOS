//
//  MyProfileViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MyProfileViewController: UITableViewController {
    let dbCollection = Firestore.firestore().collection("users")
    
    
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var introduceTextField : UITextField!
    
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.onTouchupSave(_:)))
        
        let document = dbCollection.document(UserDefaults.standard.userInfo!.phoneNumber)
        
        document.getDocument { (snapshot, error) in
            if let doc = snapshot {
                doc.data().map { info in
                    if let name = info["name"] as? String {
                        self.nameTextField.text = name
                    }
                    if let intro = info["intro"] as? String {
                        self.introduceTextField.text = intro
                    }
                }
            }
        }        
    }
    
    @objc func onTouchupSave(_ sender:UIBarButtonItem) {
        dbCollection.document(UserDefaults.standard.userInfo!.phoneNumber).setData([
        "name":nameTextField.text ?? "",
        "intro":introduceTextField.text ?? ""
    ]) { (error) in
        if let e = error {
            print(e.localizedDescription)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        }
    }
}
