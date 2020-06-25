//
//  ReportModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class ReportModel : Object {
    @objc dynamic var id:String = ""
    /** 신고 사유 코드*/
    @objc dynamic var resonCode:String = "other"
    /** 신고 사유*/
    @objc dynamic var reson:String = ""
    /** 신고하는 대상의 아이디*/
    @objc dynamic var targetId:String = ""
    /** 신고하는 대상의 종류*/
    @objc dynamic var targetTypeCode:Int = 0
    /** 신고하는 리포터의 아이디*/
    @objc dynamic var reporterId:String = ""
    /** 등록일자*/
    @objc dynamic var regDtTimeIntervalSince1970 = Date().timeIntervalSince1970

    /** 검토 완료? */
    @objc dynamic var isCheck:Bool = false
    enum ResonType : String, CaseIterable {
        case spamAdvertising = "spamAdvertising"
        case sexuallyInappropriate = "sexuallyInappropriate"
        case aversion = "aversion"
        case discrimination = "discrimination"
        case fakeNews = "fakeNews"
        case violence = "violence"
        case other = "other"
    }
    
    var resonType:ResonType {
        return ResonType(rawValue: resonCode) ?? .other
    }
    
    enum TargetType:Int {
        case user = 0
        case talk = 1
        case review = 2
    }
    
    var targetType:TargetType {
        return TargetType(rawValue: targetTypeCode) ?? .user
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["reporterId","targetTypeCode"]
    }    

}

extension ReportModel {
    
    var regDt:Date {
        return Date(timeIntervalSince1970: regDtTimeIntervalSince1970)
    }
    
    /** 신고한 사람*/
    var reporter:UserInfo? {
        return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: reporterId)
    }
    
    /** 신고대상 모델*/
    var target:Object? {
        switch targetType {
        case .user:
            return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: targetId)
        case .talk:
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: targetId)
        case .review:
            return try! Realm().object(ofType: ReviewModel.self, forPrimaryKey: targetId)
        }
    }
    
    /** 신고내역 간략히*/
    var desc: String {
        var text = ""
        switch targetType {
        case .user:
            text = "[사용자] \((target as? UserInfo)?.name ?? "")"
            
        case .talk:
            text = "[대화] \((target as? TalkModel)?.text ?? "")"
        case .review:
            text = "[리뷰] \((target as? ReviewModel)?.name ?? "")"
        }
        return text
    }
    
    func check(complete:@escaping(_ isSucess:Bool)->Void) {
        let collection = FS.store.collection(FSCollectionName.REPORT)
        let data:[String:Any] = ["id":self.id, "isCheck": true]
        collection.document(self.id).updateData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(ReportModel.self, value: data, update: .modified)
                try! realm.commitWrite()
            }
            complete(error == nil)
        }
    }
    
    /** 신고 내역 동기화*/
    static func syncReports(complete:@escaping(_ isSucess:Bool)->Void) {
        let collection = FS.store.collection(FSCollectionName.REPORT)
        var query = collection.whereField("regDtTimeIntervalSince1970", isGreaterThanOrEqualTo: 0)
        if let lastReport = try! Realm().objects(ReportModel.self).sorted(byKeyPath: "regDtTimeIntervalSince1970").last {
            query = collection.whereField("regDtTimeIntervalSince1970", isGreaterThan: lastReport.regDtTimeIntervalSince1970)
        }
        query.getDocuments { (snapShot, err) in
            if let data = snapShot {
                let realm = try! Realm()
                realm.beginWrite()
                for document in data.documents {
                    realm.create(ReportModel.self, value: document.data(), update: .all)
                }
                try! realm.commitWrite()
                complete(true)
                return
            }
            complete(false)
        }
    }
    
    /** 신고  하기*/
    static func create(targetId:String, targetType:TargetType, resonType:ResonType, reson:String, complete:@escaping(_ isSucess:Bool)->Void) {
        GameManager.shared.usePoint(point: AdminOptions.shared.pointUseReportBadPosting, exp: AdminOptions.shared.expForReportBadPosting) { isSucess in
            if isSucess == false {
                GameManager.shared.showAd(popoverView: UIBarButtonItem()) {
                    ReportModel.create(targetId: targetId, targetType: targetType, resonType: resonType, reson: reson, complete: complete)
                }
                return
            }
            let now = Date().timeIntervalSince1970
            let id = "\(UUID().uuidString)_\(now)_\(UserInfo.info!.id)"
            let data:[String:Any] = [
                "id" : id,
                "resonCode" : resonType.rawValue,
                "reson" : reson,
                "targetId" : targetId,
                "targetTypeCode" : targetType.rawValue,
                "reporterId" : UserInfo.info?.id ?? "guest",
                "regDtTimeIntervalSince1970" : now
            ]
            let doc = FS.store.collection(FSCollectionName.REPORT).document(id)
            doc.setData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.create(ReportModel.self, value: data, update: .all)
                    try! realm.commitWrite()
                }
                complete(error == nil)
            }
            
        }
        
    }
}

