//
//  NoticeViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/26.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxCocoa
import RxSwift

class NoticeViewController: UIViewController {
    static var viewController : NoticeViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "noticeView") as! NoticeViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "noticeView") as! NoticeViewController
        }
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var closeBtn:UIButton!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var confirmBtn:UIButton!
    var noticeId:String? = nil
    
    var notice:NoticeModel? {
        if let id = noticeId {
            return try! Realm().object(ofType: NoticeModel.self, forPrimaryKey: id)
        }
        return nil
    }
    let disoposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeBtn.setImage(.closeBtnImage_normal, for: .normal)
        closeBtn.setImage(.closeBtnImage_highlighted, for: .highlighted)
        closeBtn.tintColor = .autoColor_text_color
        if Consts.isAdmin {
            confirmBtn.setTitle("edit".localized, for: .normal)
        } else {
            confirmBtn.setTitle("confirm".localized, for: .normal)
        }
        
        confirmBtn.rx.tap.bind {[weak self](action) in
            guard let s = self else {
                return
            }
            if Consts.isAdmin {
                let vc = PostNoticeViewController.viewController
                vc.noticeId = s.noticeId
                let nc = UINavigationController(rootViewController: vc)
                s.present(nc, animated: true, completion: nil)
            } else {
                if s.notice?.isRead == false {
                    s.notice?.read()
                }
                s.dismiss(animated: true, completion: nil)
            }
        }.disposed(by: disoposebag)
        
        NotificationCenter.default.addObserver(forName: .noticeUpdateNotification, object: nil, queue: nil) { [weak self](notification) in
            self?.loadData()
        }
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setBorder(borderColor: .autoColor_weak_text_color, borderWidth: 0.5)
        contentView.setBorder(borderColor: .autoColor_text_color, borderWidth: 0.5, radius: 20, masksToBounds: true)
    }
    
    func loadData() {
        titleLabel.text = notice?.title
        textView.text = notice?.text
    }
    
    @IBAction func onTouchupCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
