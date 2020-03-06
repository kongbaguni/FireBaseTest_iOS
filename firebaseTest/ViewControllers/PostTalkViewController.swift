//
//  PostTalkViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift

class PostTalkViewController: UIViewController {
    @IBOutlet weak var textView:UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "write talk"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(self.onTouchupSaveBtn(_:)))
    }
    
    @objc func onTouchupSaveBtn(_ sender:UIBarButtonItem) {
        if textView.text.isEmpty {
            return
        }
        
        sender.isEnabled = false
        Loading.show(viewController: self)

        let documentId = "\(UUID().uuidString)\(UserInfo.info!.id)\(Date().timeIntervalSince1970)"
        let regTimeIntervalSince1970 = Date().timeIntervalSince1970
        let creatorId = UserInfo.info!.id
        let talk = textView.text ?? ""
        let talkModel = TalkModel()
        talkModel.loadData(id: documentId, text: talk, creatorId: creatorId, regTimeIntervalSince1970: regTimeIntervalSince1970)
        talkModel.update { [weak self](sucess) in
            if self != nil {
                sender.isEnabled = true
                Loading.hide(viewController: self!)
                if sucess {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
