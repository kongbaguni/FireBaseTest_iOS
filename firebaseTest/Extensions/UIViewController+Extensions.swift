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
}
