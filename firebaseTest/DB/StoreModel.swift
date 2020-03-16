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
import FirebaseFirestore

extension Notification.Name {
    static let deletedStoreModel = Notification.Name(rawValue: "deletedStoreModelObserver")
}

class StoreModel : Object {
    enum StoreType:String {
        /** 약국*/
        case pharmacy = "01"
        /** 우체국*/
        case postoffice = "02"
        /** 농협*/
        case nh = "03"
        
        var image:UIImage {
            switch self {
            case .pharmacy:
                return #imageLiteral(resourceName: "pharmacy").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate).withTintColor(.text_color)
            case .postoffice:
                return #imageLiteral(resourceName: "postoffice").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate).withTintColor(.text_color)
            case .nh:
                return #imageLiteral(resourceName: "NH_icon").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate).withTintColor(.text_color)
                
            }
        }
    }
    
    enum RemainType:String {
        //        재고 상태[100개 이상(녹색): 'plenty' / 30개 이상 100개미만(노랑색): 'some' / 2개 이상 30개 미만(빨강색): 'few' / 1개 이하(회색): 'empty' / 판매중지: 'break']
        //        녹색(100개 이상)/노랑색(30~99개)/빨강색(2~29개)/회색(0~1개)
        /** 1개 이하*/
        case empty = "empty"
        /** 많음 100개 이상*/
        case plenty = "plenty"
        /** 약간 30개 이상*/
        case some = "some"
        /** 2개 이상 30개 미만 */
        case few = "few"
        /** 중지*/
        case `break` = "break"
        
        var colorValue:UIColor {
            switch self {
            case .plenty:
                return UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
            case .some:
                return UIColor(red: 0.9, green: 0.7, blue: 0, alpha: 1)
            case .few:
                return UIColor(red: 0.6, green: 0.0, blue: 0, alpha: 1)
            case .empty:
                return UIColor(white: 0.6, alpha: 1)
            case .break:
                return UIColor(white: 0.4, alpha: 1)
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
    
    @objc dynamic var searchDisance:Int = Consts.DISTANCE_STORE_SEARCH
    
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
        createdDt = (data["created_at"] as? String)?.dateValue(format: "yyyy/MM/dd HH:mm:ss") ?? Date(timeIntervalSince1970: 0)
        lat = data["lat"] as? Double ?? 0
        lng = data["lng"] as? Double ?? 0
        name = data["name"] as? String ?? ""
        remain_stat = data["remain_stat"] as? String ?? "empty"
        stockDt = (data["stock_at"] as? String)?.dateValue(format: "yyyy/MM/dd HH:mm:ss") ?? Date(timeIntervalSince1970: 0)
        type = data["type"] as? String ?? ""
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
    
    var dbCollection:Query {
        let collection = Firestore.firestore().collection("storeStock")
        collection
            .whereField("regDtTimeIntervalSince1970", isGreaterThan: Date.getMidnightTime(beforDay: 7))
        return collection
            .whereField("shopcode", isEqualTo: self.code)
    }
    
    
    func getStoreStockLogs(complete:@escaping(_ count:Int?)->Void) {
        dbCollection.getDocuments { (shot, error) in
            if error != nil {
                complete(nil)
                return
            }
            guard let snap = shot else {
                complete(nil)
                return
            }
            let realm = try! Realm()
            
            print("----------------")
            print(self.name)
            realm.beginWrite()
            realm.delete(realm.objects(StoreStockLogModel.self).filter("code = %@", self.code))
            try! realm.commitWrite()
            for doc in snap.documents {
                let data = doc.data()
                if let id = data["id"] as? String
                    , let remain_stat = data["remain_stat"] as? String
                    , let storeCode = data["shopcode"] as? String
                {
                    let lastLog = realm.objects(StoreStockLogModel.self).filter("code = %@", storeCode).sorted(byKeyPath: "regDt").last
                                        
                    print("last : \(lastLog?.regDt.simpleFormatStringValue ?? " ") : \(lastLog?.remain_stat ?? " ") \(lastLog?.code ?? " ")")
                    print(Date(timeIntervalSince1970: doc["regDtTimeIntervalSince1970"] as! Double).simpleFormatStringValue
                        + " " + remain_stat + " " + storeCode)
                    if lastLog?.remain_stat != remain_stat {
                        let logModel = StoreStockLogModel()
                        logModel.id = id
                        logModel.code =  storeCode
                        logModel.remain_stat = remain_stat
                        logModel.uploaded = true
                        if let int = data["regDtTimeIntervalSince1970"] as? Double {
                            logModel.regDt = Date(timeIntervalSince1970: int)
                        }
                        realm.beginWrite()
                        realm.add(logModel, update: .all)
                        try! realm.commitWrite()
                    }
                }
            }
            complete(snap.documents.count)
        }
        
    }
}
