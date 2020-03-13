//
//  StoreModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/11.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
extension Notification.Name {
    static let deletedStoreModel = Notification.Name(rawValue: "deletedStoreModelObserver")
}

class StoreModel : Object {
    enum StoreType:String {
        case pharmacy = "01"
        case postoffice = "02"
        
        var image:UIImage {
            switch self {
            case .pharmacy:
                return #imageLiteral(resourceName: "pharmacy").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate).withTintColor(.text_color)
            case .postoffice:
                return #imageLiteral(resourceName: "postoffice").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate).withTintColor(.text_color)

            }
        }
    }
    
    enum RemainType:String {
//        녹색(100개 이상)/노랑색(30~99개)/빨강색(2~29개)/회색(0~1개)
        case empty = "empty"
        /** 많음*/
        case plenty = "plenty"
        /** 약간*/
        case some = "some"
        /** 적음*/
        case few = "few"
        
        var colorValue:UIColor {
            switch self {
            case .plenty:
                return UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
            case .some:
                return UIColor(red: 0.9, green: 0.7, blue: 0, alpha: 1)
            case .few:
                return UIColor(red: 0.6, green: 0.0, blue: 0, alpha: 1)
            default:
                return .gray
            }
        }
    }
    
    
    
    @objc dynamic var addr:String = ""
    @objc dynamic var code:String = ""
    @objc dynamic var createdDt:Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var lat:Double = 0
    @objc dynamic var lng:Double = 0
    @objc dynamic var name:String = ""
    @objc dynamic var remain_stat:String = ""
    @objc dynamic var stockDt:Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var type:String = ""
    @objc dynamic var updateDt:Date = Date()
    @objc dynamic var distance:Double = 0

    /** 거리 구하기*/
    func getLiveDistance(coodinate:CLLocationCoordinate2D)->Double {
        let a = CLLocation(latitude: lat, longitude: lng)
        let b = CLLocation(latitude: coodinate.latitude, longitude: coodinate.longitude)
        return a.distance(from: b)
    }
    
    /** 위치정보*/
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    /** 스토어 타입*/
    var storeType:StoreType? {
        return StoreType(rawValue: type)
    }
    
    /** 재고 타입*/
    var remainType:RemainType? {
        return RemainType(rawValue: remain_stat)
    }
    
    var stockDtStr:String {
        if stockDt == Date(timeIntervalSince1970: 0) {
            return "none".localized
        }
        return stockDt.relativeTimeStringValue
    }
    
    override static func primaryKey() -> String? {
           return "code"
    }
    
    func setJson(data:[String:Any]) {
        code = data["code"] as! String
        addr = data["addr"] as? String ?? ""
        createdDt = (data["created_at"] as? String)?.dateValue(format: "yyyy/MM/dd hh:mm:ss") ?? Date(timeIntervalSince1970: 0)
        lat = data["lat"] as? Double ?? 0
        lng = data["lng"] as? Double ?? 0
        name = data["name"] as? String ?? ""
        remain_stat = data["remain_stat"] as? String ?? "empty"
        stockDt = (data["stock_at"] as? String)?.dateValue(format: "yyyy/MM/dd hh:mm:ss") ?? Date(timeIntervalSince1970: 0)
        type = data["type"] as? String ?? ""
        print(remain_stat)
        if let last = UserDefaults.standard.lastMyCoordinate {
            let a = CLLocation(latitude: lat, longitude: lng)
            let b = CLLocation(latitude: last.latitude, longitude: last.longitude)
            distance = a.distance(from: b)
        }
    }
    /** 로컬DB에서 스토어 정보를 전부 삭제함*/
    static func deleteAll() {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(realm.objects(StoreModel.self))
        try! realm.commitWrite()
        NotificationCenter.default.post(name: .deletedStoreModel, object: nil, userInfo: nil)
    }
}
