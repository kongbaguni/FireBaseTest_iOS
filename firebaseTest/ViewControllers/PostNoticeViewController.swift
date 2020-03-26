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
    
    @IBOutlet weak var noticeTextView: UITextView!
    @IBOutlet weak var isShowOptionLabel: UILabel!
    @IBOutlet weak var isShowOptionSwitch: UISwitch!
    
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
        
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close".localized, style: .plain, target: self, action: #selector(self.onTouchupCloseBtn(_:)))
        }
    }
    
    func loadData() {
        isShowOptionLabel.text = "isShowNotice".localized
        titleTextField.text = notice?.title
        noticeTextView.text = notice?.text
        isShowOptionSwitch.isOn = notice?.isShow ?? false
    }
    
    let loading = Loading()
    
    @objc func onTouchupCloseBtn(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onTouchupSaveBtn(_ sender:UIBarButtonItem) {
        guard let title = titleTextField.text?.trimmingCharacters(in: CharacterSet(charactersIn: " ")),
            let text = noticeTextView.text?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) else {
                return
        }
        if title.isEmpty || text.isEmpty {
            Toast.makeToast(message: "There is no content.".localized)
            return
        }
        
        if let notice = self.notice {
            notice.edit(title: title, text: text, isShow: isShowOptionSwitch.isOn) { [weak self] (sucess) in
                if sucess {
                    self?.loading.hide()
                    self?.exit()
                }
            }
        } else {
            NoticeModel.create(title: title, text: text, isShow: isShowOptionSwitch.isOn) { [weak self](sucess) in
                if sucess {
                    self?.loading.hide()
                    self?.exit()
                }

            }
        }
    }
    
    func exit() {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
