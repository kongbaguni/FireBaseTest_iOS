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
    var documentId:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "write talk".localized
        if documentId != nil {
            title = "edit talk".localized
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(self.onTouchupSaveBtn(_:)))
        
        if let id = documentId {
            let document = try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
            textView.text = document?.text
        }
    }
    
    @objc func onTouchupSaveBtn(_ sender:UIBarButtonItem) {
        if textView.text.isEmpty {
            return
        }
        sender.isEnabled = false
        Loading.show(viewController: self)
        if let id = documentId {
            let realm = try! Realm()
            if let document = try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id) {
                realm.beginWrite()
                document.text = textView.text
                document.modifiedTimeIntervalSince1970 = Date().timeIntervalSince1970
                try! realm.commitWrite()
                document.update { [weak self] (isSucess) in
                    if self != nil {
                        sender.isEnabled = true
                        Loading.hide(viewController: self!)
                        if isSucess {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            return
        }
        
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
