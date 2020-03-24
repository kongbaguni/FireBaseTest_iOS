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
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var blurView:UIVisualEffectView!
    @IBOutlet weak var statusCardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelTitleLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var expTitleLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var expProgressView: UIProgressView!
    
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var pointTitleLabel: UILabel!
    
    @IBOutlet weak var introduceLabel: UILabel!
    @IBOutlet weak var introduceBubble: UIImageView!
    
    @IBOutlet weak var addLevelLabel: UILabel!
    @IBOutlet weak var addPointLabel: UILabel!
    @IBOutlet weak var addExpLabel: UILabel!
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
        for view in [addExpLabel, addLevelLabel, addPointLabel] {
            view?.alpha = 0
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapGesture(_:))))
        
        let closeBtnImage =
        #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))//.withRenderingMode(.alwaysTemplate)
        if #available(iOS 13.0, *) {
            closeBtn.setImage(closeBtnImage.withTintColor(.autoColor_text_color), for: .normal)
            closeBtn.setImage(closeBtnImage.withTintColor(.autoColor_weak_text_color), for: .highlighted)
        } else {
            closeBtn.setImage(closeBtnImage, for: .normal)
            closeBtn.setImage(closeBtnImage, for: .highlighted)
        }
    }
    
    @objc func onTapGesture(_ sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func setAddLabel(value:Int,target:UILabel?) {
        if value == 0 {
            return
        }
        print(value)
        target?.alpha = 1
        
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
    }
    
    func loadData() {
        guard let user = userInfo else {
            if userId == "guest" {
                nameLabel.text = "guest".localized
            } else {
                nameLabel.text = self.userId ?? "unknown people".localized
            }
            pointLabel.text = ""
            levelLabel.text = ""
            expLabel.text = ""
            levelTitleLabel.isHidden = true
            pointTitleLabel.isHidden = true
            expProgressView.progress = 0
            expTitleLabel.isHidden = true
            return
        }
        
        profileImageView.kf.setImage(with: user.profileImageURL, placeholder:#imageLiteral(resourceName: "profile"))
        nameLabel.text = user.name
        introduceBubble.image = UIApplication.shared.isDarkMode ? #imageLiteral(resourceName: "bubble_dark") : #imageLiteral(resourceName: "bubble_light")
        introduceLabel.text = user.introduce
        pointLabel.text = user.point.decimalForamtString
        levelLabel.text = user.levelStrValue
        levelLabel.textColor = .autoColor_bold_text_color

        func setExp(exp:Int,animated:Bool) {
            let maxExp = Consts.LEVELUP_REQ_EXP
            let newProgress = Float(exp) / Float(maxExp)
            if animated {
                expProgressView.setProgress(newProgress, animated: true)
            } else {
                expProgressView.progress = newProgress
            }
            expLabel.text = "\(exp.decimalForamtString)/\(maxExp.decimalForamtString)"
        }
        
        if let change = statusChange {
            var oldExp = user.exp - change.addedExp
            if oldExp < 0 {
                oldExp = 0
                self.setAddLabel(value: 1, target: self.addLevelLabel)
                levelLabel.text = user.level.decimalForamtString
                levelLabel.textColor = .autoColor_weak_text_color
            }
            pointLabel.text = (user.point - change.pointChange).decimalForamtString
            setExp(exp: oldExp, animated: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
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
}
