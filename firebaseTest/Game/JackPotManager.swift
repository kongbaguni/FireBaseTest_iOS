//
//  JackPotManager.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

extension Notification.Name {
    static let jackpotChangeNotification = Notification.Name("jackPodChangeObserver")
}

class JackPotManager {
    static let shared = JackPotManager()
    fileprivate let dbcollection = FS.store.collection(FSCollectionName.JACKPOT)
    
    var point:Int = AdminOptions.shared.minJackPotPoint
    
    func getData(complete:@escaping(_ isSucess:Bool)->Void) {
        let doc = dbcollection.document("point")
        doc.getDocument { (snapshot, error) in
            guard let doc = snapshot else {
                complete(false)
                return
            }
            doc.data().map { (info) in
                self.point = info["point"] as? Int ?? AdminOptions.shared.minJackPotPoint
            }
            complete(error == nil)
        }
    }
        
    func addPoint(_ value:Int, complete:@escaping(_ isSucess:Bool)->Void) {
        var p = point + value
        if p > AdminOptions.shared.maxJackPotPoint {
            p = AdminOptions.shared.maxJackPotPoint
        }
        addJackPotHistoryLog(jackPotPoint: value) { [weak self](sucess) in
            if sucess {
                self?.setPoint(p, complete: complete)
            }
            else {
                complete(false)
            }
        }
    }
    
    fileprivate func setPoint(_ value:Int, complete:@escaping(_ isSucess:Bool)->Void) {
        dbcollection.document("point").setData(["point":value]) { (err) in
            if err == nil {
                self.getData { (isSucess) in
                    complete(isSucess)
                    if isSucess {
                        NotificationCenter.default.post(name: .jackpotChangeNotification, object: value)
                    }
                }
            } else {
                complete(false)
            }
        }
    }
    
    /** 잭팟 로그 작성.  잭팟 적립은 젝팟 포인트 양수로  잭팟  지금은 은 음수로 입력.*/
    fileprivate func addJackPotHistoryLog(jackPotPoint:Int, complete:@escaping(_ isSucess:Bool)->Void) {
        let id = "\(UUID().uuidString)\(UserInfo.info!.id)\(Date().timeIntervalSince1970)"
        dbcollection.document("history").collection("log").addDocument(data: [
            "regTimeIntervalSince1970":Date().timeIntervalSince1970,
            "userId":UserInfo.info?.id ?? "",
            "point":jackPotPoint,
            "id": id
        ]) { (error) in
            complete(error == nil)
        }
    }

    func getJackPotHistoryLog(complete:@escaping(_ isSucess:Bool)->Void) {
        let collection = dbcollection.document("history").collection("log")
        var query = collection.whereField("regTimeIntervalSince1970", isGreaterThan: Date.getMidnightTime(beforDay: 360).timeIntervalSince1970)
        
        if let item = try! Realm().objects(JackPotLogModel.self).sorted(byKeyPath: "regTimeIntervalSince1970").last {
            query = collection.whereField("regTimeIntervalSince1970", isGreaterThan: item.regTimeIntervalSince1970)
        }
        
        query.getDocuments { (queryshot, error) in
            if error != nil {
                complete(false)
                return
            }
            guard let doc = queryshot else {
                complete(false)
                return
            }
            let realm = try! Realm()
            realm.beginWrite()
            for document in doc.documents {
                let data = document.data()
                realm.create(JackPotLogModel.self, value: data, update: .all)
            }
            try! realm.commitWrite()
            complete(true)
        }
    }
    
    func dropJackPot(complete:@escaping(_ jackpotPoint:Int?)->Void) {
        let jackPot = self.point
        setPoint(AdminOptions.shared.minJackPotPoint) { (isSucess) in
            if isSucess == false {
                complete(nil)
            } else {
                self.addJackPotHistoryLog(jackPotPoint: -jackPot) { (isSucess) in
                    if isSucess {
                        self.getData { (isSucess) in
                            if isSucess {
                                complete(jackPot)
                            } else {
                                complete(nil)
                            }
                        }
                    } else {
                        complete(nil)
                    }
                }
            }
        }
    }
    
}
