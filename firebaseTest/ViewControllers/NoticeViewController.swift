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

class NoticeViewController: UIViewController {
    static var viewController : NoticeViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "noticeView") as! NoticeViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "noticeView") as! NoticeViewController
        }
    }
    
    @IBOutlet weak var closeBtn:UIButton!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var textView:UITextView!
    
    var noticeId:String? = nil
    
    var notice:NoticeModel? {
        if let id = noticeId {
            return try! Realm().object(ofType: NoticeModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = notice?.title
        textView.text = notice?.text
        let closeBtnImage =
        #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))
        closeBtn.setImage(closeBtnImage, for: .normal)        
    }
    
    @IBAction func onTouchupCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
