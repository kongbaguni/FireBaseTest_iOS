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
    @objc dynamic var isPurchase:Bool = false
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension InAppPurchaseModel {

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
                "title" : product.localizedTitle,
                "desc" : product.localizedDescription,
                "price" : product.price.floatValue,
                "priceLocaleId" : product.priceLocale.identifier,
            ]
            realm.create(InAppPurchaseModel.self, value: data, update: .modified)
        }
        try! realm.commitWrite()
    }
    
    static func set(productId:String, isPurchase:Bool) {
        let data:[String:Any] = [
            "id":productId,
            "isPurchase":isPurchase
        ]
        let realm = try! Realm()
        realm.beginWrite()
        realm.create(InAppPurchaseModel.self, value: data, update: .modified)
        try! realm.commitWrite()        
    }
    
    static func model(productId:String)->InAppPurchaseModel? {
        return try! Realm().object(ofType: InAppPurchaseModel.self, forPrimaryKey: productId)
    }
}
