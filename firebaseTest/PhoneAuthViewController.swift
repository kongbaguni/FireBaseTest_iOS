//
//  PhoneAuthViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseAuth
import PhoneNumberKit

class PhoneAuthViewController: UIViewController {
    class var viewController : PhoneAuthViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "phoneNumberInput") as! PhoneAuthViewController
    }
    @IBOutlet weak var phoneNumberTextField:PhoneNumberTextField!
    @IBAction func onTouchupConfirmBtn(sender:UIButton) {
        Auth.auth().languageCode = "kr"
        if let phoneNumber = phoneNumberTextField.text?.phoneNumberFormat(format: .e164) {
            if !phoneNumber.isEmpty {
                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self](verificationID, err) in
                    print(err?.localizedDescription ?? "에러 없음")
                    if err == nil {
                        if let id = verificationID {
                            self?.navigationController?.performSegue(withIdentifier: "showInputCode", sender: nil)
                            
                            UserDefaults.standard.userInfo = UserInfo(phoneNumber: phoneNumber, authVerificationID: id)
                        }
                    }
                }
            }
        }
    }
}
