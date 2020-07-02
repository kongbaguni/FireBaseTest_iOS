//
//  RewordPointResultViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/07/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
class RewordPointResultViewController: UIViewController {
    static var viewController : RewordPointResultViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "InAppPurchase", bundle: nil).instantiateViewController(identifier: "rewordPointAlert")
        } else {
            return UIStoryboard(name: "InAppPurchase", bundle: nil).instantiateViewController(withIdentifier: "rewordPointAlert") as! RewordPointResultViewController
        }
    }
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    var bonusPoint:GameManager.BonusPoint? = nil
    var didDismissAction:()->Void = {
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            self.didDismissAction()
        }
    }
    // ------------------
    // 리워드 포인트 : 500
    // 보너스 : 5배
    // 획득 포인트 : 2500
    // ------------------
    // 나의 포인트 : 4000
    enum CellType:String {
        case rewordPoints = "rewordPoints"
        case bonusMultiple = "bonusMultiple"
        case getPoints = "getPoints"
        case myPoints = "myPoints"
    }
    var step = 0
    var cellTypes:[[CellType]] {
        switch step {
        case 0:
            return [
                [.myPoints]
            ]
        case 1:
            return [
                [.rewordPoints],
                [.myPoints]
            ]
        default:
            return [
                [.rewordPoints,
                 .bonusMultiple,
                 .getPoints],
                [.myPoints]
            ]
        }
    }
    
    @IBOutlet weak var frontBlurView: UIVisualEffectView!
    
    private func tableViewSizeFit() {
        let newSize = tableView.sizeThatFits(CGSize(width:tableView.frame.width , height: UIScreen.main.bounds.height))
            
        tableViewHeight.constant = newSize.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
        view.addGestureRecognizer(gesture)
        tableView.reloadData()
        tableViewSizeFit()
        view.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {[weak self] in
            self?.view.alpha = 1
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            self?.frontBlurView.alpha = 0
        }) { [weak self] (finish) in
            self?.step = InAppPurchaseModel.isSubscribe ? 2 : 1
            self?.tableView.reloadData()
            self?.tableViewSizeFit()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {[weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func onTap(_ sender:UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.setBorder(borderColor: .autoColor_text_color, borderWidth: 0.5, radius: 20, masksToBounds: true)
    }
}

extension RewordPointResultViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = cellTypes[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = type.rawValue.localized
        var detailText:String {
            switch type {
            case .rewordPoints:
                return AdminOptions.shared.adRewardPoint.decimalForamtString
            case .myPoints:
                if let point = UserInfo.info?.point {
                    let p1 = point - (bonusPoint?.finalPoint ?? 0)
                    switch step {
                    case 0:
                        return p1.decimalForamtString
                    case 1:
                        return (p1 + AdminOptions.shared.adRewardPoint).decimalForamtString
                    default:
                        return point.decimalForamtString
                    }
                }
                return "0"
            case .bonusMultiple:
                return bonusPoint?.bonusMultiple.decimalForamtString ?? "1"
            case .getPoints:
                return bonusPoint?.finalPoint.decimalForamtString ?? "0"
            }
        }
        cell.detailTextLabel?.text = detailText                
        return cell
    }
}
