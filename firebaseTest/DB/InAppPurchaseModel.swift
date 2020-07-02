//
//  InAppPurchaseModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyStoreKit

class InAppPurchaseModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var title:String = ""
    @objc dynamic var desc:String = ""
    @objc dynamic var price:Float = 0
    @objc dynamic var priceLocaleId:String = ""
    @objc dynamic var expireDate:Date = Date(timeIntervalSince1970: 0)
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension InAppPurchaseModel {
    
    var isExpire:Bool {
        return expireDate < Date()
    }

    var localeFormatedPrice:String? {
        let locale = Locale(identifier: priceLocaleId)
        return price.getFormatString(locale: locale, style: .currency)
    }
    
    static var isEmpty:Bool {
        let list = try! Realm().objects(InAppPurchaseModel.self)
        return list.count == 0
    }
    
    static func make(result:RetrieveResults) {
        let realm = try! Realm()
        realm.beginWrite()
        for product in result.retrievedProducts {            
            let data:[String:Any] = [
                "id": product.productIdentifier,
                "title" : product.localizedTitle.isEmpty ? (InAppPurchase.title[product.productIdentifier] ?? "") : product.localizedTitle,
                "desc" : product.localizedDescription.isEmpty ? (InAppPurchase.desc[product.productIdentifier] ?? "") : product.localizedDescription,
                "price" : product.price.floatValue,
                "priceLocaleId" : product.priceLocale.identifier,
            ]
            realm.create(InAppPurchaseModel.self, value: data, update: .modified)
        }
        try! realm.commitWrite()
    }
    
    static func set(productId:String, expireDt:Date?) {
        let data:[String:Any] = [
            "id":productId,
            "expireDate":expireDt ?? Date(timeIntervalSince1970: 0)
        ]
        let realm = try! Realm()
        realm.beginWrite()
        realm.create(InAppPurchaseModel.self, value: data, update: .modified)
        try! realm.commitWrite()        
    }
    
    static func model(productId:String)->InAppPurchaseModel? {
        return try! Realm().object(ofType: InAppPurchaseModel.self, forPrimaryKey: productId)
    }
    
    /** 구독중인가?*/
    static var isSubscribe:Bool {
        let list = try! Realm().objects(InAppPurchaseModel.self)
        for model in list {
            if model.isExpire == false {
                return true
            }
        }
        return false
    }
    
}
