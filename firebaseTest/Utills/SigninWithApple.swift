//
//  SigninWithApple.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/09.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class SigninWithApple : NSObject {
    weak var targetVC:UIViewController? = nil
    init(controller:UIViewController) {
        targetVC = controller
    }
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    @available(iOS 13.0, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    @available(iOS 13.0, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

@available(iOS 13.0, *)
extension SigninWithApple : ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        targetVC?.alert(title: "Sign in with Apple errored", message: error.localizedDescription);
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                let msg = "Invalid state: A login callback was received, but no login request was sent."
                targetVC?.alert(title: "Sign in with Apple errored", message: msg)
                fatalError(msg)
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                let msg = "Unable to fetch identity token"
                debugPrint(msg)
                targetVC?.alert(title: "Sign in with Apple errored", message: msg);
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                let msg = "Unable to serialize token string from data: \(appleIDToken.debugDescription)"
                print(msg)
                targetVC?.alert(title: "Sign in with Apple errored", message: "msg");
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            
            Auth.auth().signIn(with: credential) { [weak self](authResult, error) in
                
                if let err = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(err.localizedDescription)
                    self?.targetVC?.alert(title: "Sign in with Apple errored", message: err.localizedDescription);
                    return
                } else {
                    if UserInfo.info == nil {
                        authResult?.saveUserInfo(idToken: idTokenString, accessToken: "") { isNewUser in
                            if let isNew = isNewUser {
                                StoreModel.deleteAll()
                                AdminOptions.shared.getData {
                                    if isNew {
                                        let vc = MyProfileViewController.viewController
                                        vc.hideLeaveCell = true
                                        UIApplication.shared.rootViewController = UINavigationController(rootViewController: vc)
                                    }
                                    else {
                                        UIApplication.shared.rootViewController  = MainTabBarController.viewController
                                    }
                                }
                            }
                            else {
                                Toast.makeToast(message: "error")
                            }
                        }
                    } else {
                        AdminOptions.shared.getData {
                            UIApplication.shared.rootViewController  = MainTabBarController.viewController
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 13.0, *)
extension SigninWithApple : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return (targetVC?.view.window)!
    }
    
}
