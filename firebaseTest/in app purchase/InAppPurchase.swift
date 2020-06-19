//
//  InAppPurchase.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import RealmSwift
struct InAppPurchase {
    static let productIdSet:Set<String> = ["adPoint2x","adPoint4x","adPoint10x"]

    /** 인앱 결재 제품 정보 얻어오기*/
    static func getProductInfo(force:Bool = false, complete:@escaping()->Void) {
        if InAppPurchaseModel.isEmpty == true || force {
            SwiftyStoreKit.retrieveProductsInfo(productIdSet) { (results) in
                InAppPurchaseModel.make(result: results)
                complete()
            }
        } else {
            complete()
        }
    }
    
    /** 구매내역 복원 */
    static func verifyPurchase(complete:@escaping(_ isSucess:Bool)->Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
        
        func verify() {
            SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { (result) in
                switch result {
                case .success(let receipt):
                    for productId in InAppPurchase.productIdSet {
                        let purchaseResult = SwiftyStoreKit.verifyPurchase(
                            productId: productId,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let receiptItem):
                            print("\(productId) is purchased \(receiptItem.productId)")
                            InAppPurchaseModel.set(productId: productId, isEnable: true)
                        case .notPurchased:
                            print("The user has never purchased \(productId)")
                            InAppPurchaseModel.set(productId: productId, isEnable: false)
                        }
                    }
                    complete(true)
                case .error(let error):
                    print("Receipt verification failed: \(error)")
                    complete(false)
                }
            }
        }
        
        if InAppPurchaseModel.isEmpty {
            SwiftyStoreKit.retrieveProductsInfo(productIdSet) { (results) in
                InAppPurchaseModel.make(result: results)
                verify()
            }
        } else {
            verify()
        }
    }
    
    /** 제품 구입 */
    static func buyProduct(productId:String,complete:@escaping(_ isSucess:Bool)->Void) {
          SwiftyStoreKit.purchaseProduct(productId) { (result) in
              switch result {
              case .success(let purchase):
                  print("Purchase Success: \(purchase.productId)")
                  complete(true)
              case .error(let error):
                  switch error.code {
                  case .unknown: print("Unknown error. Please contact support")
                  case .clientInvalid: print("Not allowed to make the payment")
                  case .paymentCancelled: break
                  case .paymentInvalid: print("The purchase identifier was invalid")
                  case .paymentNotAllowed: print("The device is not allowed to make the payment")
                  case .storeProductNotAvailable: print("The product is not available in the current storefront")
                  case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                  case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                  case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                  default: print((error as NSError).localizedDescription)
                  }
                  complete(false)
              }
          }
      }
}
