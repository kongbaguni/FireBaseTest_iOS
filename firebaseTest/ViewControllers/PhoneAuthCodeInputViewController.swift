//
//  PhoneAuthCodeInputViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseAuth

class PhoneAuthCodeInputViewController: UIViewController {
    deinit {
        debugPrint("deinit \(#file)")
    }

    @IBOutlet weak var codeTextField:UITextField!
    @IBAction func onTouchupConfirmBtn(sender:UIButton) {
        guard let verificationCode = codeTextField.text,
            let userInfo = UserDefaults.standard.userInfo else {
            return
        }
        if verificationCode.isEmpty {
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: userInfo.authVerificationID,
            verificationCode: verificationCode)

        Auth.auth().signIn(with: credential) { [weak self](authResult, error) in
            if error == nil {
                self?.navigationController?.viewControllers = [MainViewController.viewController]
            }            
        }

    }
}
