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
    static let productIdSet:Set<String> = ["weeklyADBonus","monthlyADBonus","6monthsADBonus","yearlyADBonus"]
    
    static let title:[String:String] = [
        "weeklyADBonus":"주간",
        "monthlyADBonus":"월간",
        "6monthsADBonus":"6개월",
        "yearlyADBonus":"연간"
    ]
    
    static let desc:[String:String] = [
        "weeklyADBonus":"1주일간 광고시청후 받는 리워드 포인트가 3~10배로 증가합니다.",
        "monthlyADBonus":"한달동안 광고시청후 받는 리워드 포인트가 3~10배로 증가합니다.",
        "6monthsADBonus":"6개월간 광고시청후 받는 리워드 포인트가 3~10배로 증가합니다.",
        "yearlyADBonus":"1년동안 광고시청후 받는 리워드 포인트가 3~10배로 증가합니다."
    ]
    
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
    static func restorePurchases(complete:@escaping(_ isSucess:Bool)->Void) {
        func restore() {
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "27aa41384d2f48d6b78eeac367079f4c")
            
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { (result) in
                switch result {
                case .success(let receipt):
                    for id in InAppPurchase.productIdSet {
                        let sresult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: id, inReceipt: receipt)
                        switch sresult {
                        case .expired(let expiryDate, let items):
                            print("expired : \(expiryDate.simpleFormatStringValue)")
                            for item in items {
                                print("\(item.productId) \(item.purchaseDate.simpleFormatStringValue)")
                            }
                            InAppPurchaseModel.set(productId: id, expireDt: expiryDate)
                            break
                        case .purchased(let expiryDate, let items):
                            print("purchased : \(expiryDate.simpleFormatStringValue)")
                            for item in items {
                                print("\(item.productId) \(item.purchaseDate.simpleFormatStringValue)")
                            }
                            UserDefaults.standard.lastInAppPurchaseExpireDate = expiryDate
                            InAppPurchaseModel.set(productId: id, expireDt: expiryDate)
                            break
                        default:
                            InAppPurchaseModel.set(productId: id,  expireDt: nil)
                            break
                        }
                    }
                    complete(true)
                case .error(let error):
                    print(error.localizedDescription)
                    complete(false)
                }
            }
        }
        
        if InAppPurchaseModel.isEmpty {
            SwiftyStoreKit.retrieveProductsInfo(productIdSet) { (results) in
                InAppPurchaseModel.make(result: results)                
                restore()
            }
        } else {
            restore()
        }
    }
    
    /** 제품 구입 */
    static func buyProduct(productId:String,complete:@escaping(_ isSucess:Bool)->Void) {
        SwiftyStoreKit.purchaseProduct(productId) { (result) in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                for id in InAppPurchase.productIdSet {
                    InAppPurchaseModel.set(productId: id, expireDt: nil)
                }
                InAppPurchaseModel.set(productId: productId, expireDt: Date(timeIntervalSinceNow: 100000))
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
