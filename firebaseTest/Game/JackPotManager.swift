//
//  JackPotManager.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseFirestore
extension Notification.Name {
    static let jackpotChangeNotification = Notification.Name("jackPodChangeObserver")
}

class JackPotManager {
    static let shared = JackPotManager()
    
    fileprivate let dbcollection = Firestore.firestore().collection("jackPot")
    
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
        dbcollection.document("point").setData(["point":p]) { (err) in
            if err == nil {
                self.getData { (isSucess) in
                    complete(isSucess)
                    if isSucess {
                        NotificationCenter.default.post(name: .jackpotChangeNotification, object: p)
                    }
                }
            } else {
                complete(false)
            }
        }
    }
    
}
