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
    static let productIdSet:Set<String> = ["ad_point2x","ad_point5x","ad_point10x"]
    
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
            SwiftyStoreKit.restorePurchases { (result) in
                let restoredList = result.restoredPurchases.filter { (p) -> Bool in
                    switch p.transaction.transactionState {
                    case .purchased, .restored:
                        return true
                    default:
                        return false
                    }
                }
                let list = restoredList.sorted { (a, b) -> Bool in
                    let d1 = a.transaction.transactionDate ?? Date(timeIntervalSince1970: 0)
                    let d2 = b.transaction.transactionDate ?? Date(timeIntervalSinceReferenceDate: 0)
                    return d1 > d2
                }
                for id in InAppPurchase.productIdSet {
                    InAppPurchaseModel.set(productId: id, isPurchase: list.first?.productId == id)
                }
                complete(result.restoredPurchases.count > 0)
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
                    InAppPurchaseModel.set(productId: id, isPurchase: false)
                }
                InAppPurchaseModel.set(productId: productId, isPurchase: true)
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
