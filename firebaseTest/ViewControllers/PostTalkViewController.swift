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
    
    var document:TalkModel? {
        if let id = documentId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "write talk".localized
        if documentId != nil {
            title = "edit talk".localized
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(self.onTouchupSaveBtn(_:)))
        
        textView.text = document?.text
        if let text = document?.editList.last?.text {
            textView.text = text
        }
        textView.becomeFirstResponder()
    }
    
    @objc func onTouchupSaveBtn(_ sender:UIBarButtonItem) {
        func write() {
            let text = textView.text.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                   print("--------------")
                   print(text)
                   print("--------------")
                   print(document?.text ?? "없네?")
                   print("--------------")
                   var isEdit:Bool {
                       if let edit = document?.editList.last {
                           return text != edit.text
                       }
                       return text != document?.text
                   }
                   if isEdit == false {
                       Toast.makeToast(message: "There are no edits.".localized)
                       return
                   }
                   if text.isEmpty {
                       Toast.makeToast(message: "There is no content.".localized)
                       return
                   }
                   view.endEditing(true)
                   sender.isEnabled = false
                   Loading.show(viewController: self)
                   if let id = documentId {
                       let realm = try! Realm()
                       if let document = try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id) {
                           realm.beginWrite()
                           let editText = TextEditModel()
                           editText.setData(text: text)
                           document.insertEdit(data: editText)
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

        UserInfo.info?.syncData(syncAll: false, complete: { (_) in
            if UserInfo.info?.point ?? 0 < 100 {
                let msg = String(format:"Not enough points Current Point: %@".localized, UserInfo.info?.point.decimalForamtString ?? "0")
                let vc = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "Receive points".localized, style: .default, handler: { (_) in
                    //TODO 광고보기 넣을것.
                    UserInfo.info?.addPoint(point: Consts.POINT_BY_AD, complete: { (isSucess) in
                        self.onTouchupSaveBtn(sender)
                    })
                }))
                vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
                return
            }
            UserInfo.info?.addPoint(point: -Consts.POINT_FOR_WRITE, complete: { (issucess) in
                write()
            })
        })
        
    }
}
