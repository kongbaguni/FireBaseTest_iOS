//
//  UIViewController+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/09.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func alert(title:String?, message:String?, confirmText:String = "confirm".localized ,didConfirm:@escaping(_ action:UIAlertAction)->Void = {_ in }) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: confirmText, style: .cancel, handler: didConfirm))
        present(vc, animated: true, completion: nil)        
    }
    
    func unblockAlert(complete:@escaping(_ isUnblocked:Bool)->Void) {
        func unblock(complete:@escaping(_ isSucess:Bool)->Void) {
            GameManager.shared.usePoint(point: AdminOptions.shared.pointForUnblockPosting) { [weak self] (sucess) in
                if sucess {
                    UserInfo.info?.update(data: ["isBlockByAdmin":false], complete: { (sucess) in
                        self?.alert(title: nil, message: "unblock sucess msg".localized, confirmText: "confirm".localized) { (_) in
                            complete(sucess)
                        }
                        
                    })
                } else {
                    GameManager.shared.showAd(popoverView: UIBarButtonItem()) {
                        unblock(complete: complete)
                    }
                }
            }
        }

        let msg = String(format:"block by admin to unlock need point : %@".localized, AdminOptions.shared.pointForUnblockPosting.decimalForamtString)
        let vc = UIAlertController(title: "alert".localized, message: msg , preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "confirm".localized, style: .cancel, handler: { _ in
            complete(false)
        }))
        
        vc.addAction(UIAlertAction(title: "unblock".localized, style: .default, handler: { (_) in
            unblock { (isSucess) in
                complete(isSucess)
            }
        }))
        present(vc, animated: true, completion: nil)
        
    }
    
    func alertBonusPoint(bonus:GameManager.BonusPoint, didDismiss:@escaping()->Void) {
        let vc = RewordPointResultViewController.viewController
        vc.bonusPoint = bonus
        vc.didDismissAction = didDismiss
        present(vc, animated: true, completion: nil)
    }
}
