//
//  StatusViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/15.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
struct StatusChange {
    /** 얻은 경험치*/
    let addedExp:Int
    /** 포인트 변화 (증가 혹은 감소 수치) */
    let pointChange:Int
}

class StatusViewController: UIViewController {
    fileprivate var userId:String? = nil
    
    var statusChange:StatusChange? = nil
    
    var userInfo:UserInfo? {
        if let id = userId {
            return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: id)
        }
        return nil
    }
    
    @IBOutlet weak var statusViewLayoutHeight: NSLayoutConstraint!
    static func viewController(withUserId id:String?)-> StatusViewController {
        if #available(iOS 13.0, *) {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "status") as! StatusViewController
            vc.userId = id
            return vc
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "status") as! StatusViewController
            vc.userId = id
            return vc
        }
    }
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var statusCardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelTitleLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var expTitleLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var expProgressView: UIProgressView!
    @IBOutlet weak var emailTitleLabel: UILabel!
    
    @IBOutlet weak var emailBtn: UIButton!
    
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var pointTitleLabel: UILabel!
    
    @IBOutlet weak var introduceLabel: UILabel!
    @IBOutlet weak var introduceBubble: UIImageView!
    
    @IBOutlet weak var addPointLabel: UILabel!
    @IBOutlet weak var addExpLabel: UILabel!
    @IBOutlet weak var talkLogsBtn: UIButton!
    
    var isHideIntro:Bool = true {
        didSet {
            for view in [introduceLabel, introduceBubble] {
                view?.isHidden = isHideIntro
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = userId {
            if self.userInfo == nil {
                UserInfo.getUserInfo(id: id) { [weak self](complete) in
                    self?.loadData()
                }
            }
        }
        setTitle()
        loadData()
        isHideIntro = true
        statusCardView.layer.borderColor = UIColor.autoColor_text_color.cgColor
        statusCardView.layer.borderWidth = 1
        statusCardView.layer.masksToBounds = true
        statusCardView.layer.cornerRadius = 10
        for view in [addExpLabel, addPointLabel] {
            view?.alpha = 0
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapGesture(_:))))
        
        
        closeBtn.setImage(.closeBtnImage_normal, for: .normal)
        closeBtn.setImage(.closeBtnImage_highlighted, for: .highlighted)
        closeBtn.tintColor = .autoColor_text_color
                
        statusViewLayoutHeight.constant = statusChange == nil ? 200 : 150
        for view in [emailBtn, emailTitleLabel, talkLogsBtn] {
            view?.isHidden = statusChange != nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blurView.alpha = 0.0
        if self.statusChange != nil {
            UIView.animate(withDuration: 0.5) {[weak self] in
                self?.blurView.alpha = 0.5
            }
        }
        else {
            UIView.animate(withDuration: 1) {[weak self] in
                self?.blurView.alpha = 1
            }
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
////        if self.statusChange != nil {
////            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) { [weak self] in
////                self?.dismiss(animated: true, completion: nil)
////            }
////        }
//    }
    @objc func onTapGesture(_ sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func setAddLabel(value:Int,target:UILabel?) {
        if value == 0 {
            return
        }
        print(value)
        target?.alpha = 1
        target?.isHidden = false
        target?.textColor = value > 0 ? UIColor.autoColor_bold_text_color : .red
        target?.text = "\(value > 0 ? "+" : "") \(value.decimalForamtString)"
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            UIView.animate(withDuration: 0.5) {
                target?.alpha = 0
            }
        }
    }
    
    
    func setTitle() {
        levelTitleLabel.text = "level".localized
        expTitleLabel.text = "exp".localized
        pointTitleLabel.text = "point".localized
        emailTitleLabel.text = "email".localized
        talkLogsBtn.setTitle("talk logs".localized, for: .normal)
    }
    
    func loadData() {
        guard let user = userInfo else {
            if userId == "guest" {
                nameLabel.text = "guest".localized
            } else {
                nameLabel.text = userId?.components(separatedBy: "@").first
            }
            pointLabel.text = ""
            levelLabel.text = ""
            expLabel.text = ""
            levelTitleLabel.isHidden = true
            pointTitleLabel.isHidden = true
            expProgressView.progress = 0
            expTitleLabel.isHidden = true
            emailBtn.setTitle(self.userId, for: .normal)
            return
        }
        emailBtn.setTitle(user.email, for: .normal)
        profileImageView.kf.setImage(with: user.profileImageURL, placeholder:#imageLiteral(resourceName: "profile"))
        nameLabel.text = user.name
        introduceBubble.image = .bubble
        introduceLabel.text = user.introduce
        pointLabel.text = user.point.decimalForamtString
        levelLabel.text = user.levelStrValue
        levelLabel.textColor = .autoColor_bold_text_color

        func setExp(exp:Int,animated:Bool) {
            let a = user.prevLevelExp
            let b = user.nextLevelupExp
            print("prevLevelExp : \(a) nextLevelExp: \(b) user exp: \(user.exp) set exp:\(exp)")
            let newProgress = Float(exp - a) / Float(b - a)
            if animated {
                expProgressView.setProgress(newProgress, animated: true)
            } else {
                expProgressView.progress = newProgress
            }
            expLabel.text = "\((exp - a < 0 ? 0 : exp - a ).decimalForamtString)/\((b-a).decimalForamtString)"
        }
        
        if let change = statusChange {
            let oldExp = user.exp - change.addedExp
            let beforeLevel = Exp(oldExp).level
            let newLevel = user.level
            var interval:Int = 1
            if newLevel > beforeLevel {
                levelLabel.text = beforeLevel.decimalForamtString
                levelLabel.textColor = .autoColor_weak_text_color
                interval = 3
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.levelLabel.textColor = .autoColor_bold_text_color
                    self.levelLabel.text = "+\((newLevel - beforeLevel).decimalForamtString)".localized
                }
            }
            
            pointLabel.text = (user.point - change.pointChange).decimalForamtString
            setExp(exp: oldExp, animated: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(interval)) {
                setExp(exp: user.exp, animated: true)
                self.pointLabel.text = user.point.decimalForamtString
                self.setAddLabel(value: change.addedExp, target: self.addExpLabel)
                self.setAddLabel(value: change.pointChange, target: self.addPointLabel)
                self.levelLabel.text = user.levelStrValue
                self.levelLabel.textColor = .autoColor_bold_text_color
            }
            
        } else {
            setExp(exp: user.exp, animated:  false)
        }
        
    }
    
    @IBAction func onTouchupProfileBtn(_ sender: Any) {
        if self.userInfo != nil {
            isHideIntro.toggle()
        } else {
            isHideIntro = true
        }
    }
    
    @IBAction func onTouchupCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTouchupBtn(_ sender: UIButton) {
        switch sender {
        case talkLogsBtn:
            let level = AdminOptions.shared.canViewTalkLogLevel
            if level <= UserInfo.info?.level ?? 0 || userId == UserInfo.info?.id {
                let vc = TalkHistoryTableViewController.viewController
                vc.userId = self.userId
                let navi = UINavigationController(rootViewController: vc)
                navi.modalPresentationStyle = .overFullScreen
                self.present(navi, animated: true, completion: nil)
            } else {
                let msg = String(format: "err_talk_log_policy_msg %@".localized, level.decimalForamtString)
                let vc = UIAlertController(title: "You do not have permission to look up".localized, message: msg, preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "confirm".localized, style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
            }
        case emailBtn:
            if let email = self.userInfo?.email {
                email.sendMail()
            }
        default:
            break
        }
    }
}
