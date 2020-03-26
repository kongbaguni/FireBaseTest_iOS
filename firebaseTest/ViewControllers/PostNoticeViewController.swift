//
//  PostNoticeViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/26.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PostNoticeViewController: UITableViewController {
    static var viewController : PostNoticeViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "postNotice") as! PostNoticeViewController
        } else {
             return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postNotice") as! PostNoticeViewController
        }
    }
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var noticeTextField: UITextView!
    
    var noticeId:String? = nil
    
    var notice:NoticeModel? {
        guard let id = noticeId else {
            return nil
        }
        return try! Realm().object(ofType: NoticeModel.self, forPrimaryKey: id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(self.onTouchupSaveBtn(_:)))
    }
    
    func loadData() {
        titleTextField.text = notice?.title
        noticeTextField.text = notice?.text
    }
    
    let loading = Loading()
    
    @objc func onTouchupSaveBtn(_ sender:UIBarButtonItem) {
        let realm = try! Realm()
        let title = noticeTextField.text.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        let text = noticeTextField.text.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        if title.isEmpty || text.isEmpty {
            Toast.makeToast(message: "There is no content.".localized)
            return
        }
        let now = Date().timeIntervalSince1970
        
        if let notice = self.notice {
            realm.beginWrite()
            notice.text = text
            notice.title = title
            notice.updateDtTimeinterval1970 = now
            try! realm.commitWrite()
            loading.show(viewController: self)
            notice.update { [weak self](sucess) in
                if sucess {
                    self?.loading.hide()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            let notice = NoticeModel()
            notice.id = "\(UUID().uuidString)\(now)\(UserInfo.info!.id)"
            notice.title = title
            notice.text = text
            notice.regDtTimeinterval1970 = now
            notice.updateDtTimeinterval1970 = now
            notice.creatorId = UserInfo.info!.id
            
            realm.beginWrite()
            realm.add(notice, update: .all)
            try! realm.commitWrite()
            notice.update {[weak self] (sucess) in
                if sucess {
                    self?.loading.hide()
                    self?.navigationController?.popViewController(animated: true)
                }

            }
        }
        
    }
}
