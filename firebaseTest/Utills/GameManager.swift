//
//  GameManager.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
/** 포인트 사용. 경험치 축적. 게임 관리 등을 위한 클래스*/
class GameManager {
    static let shared = GameManager()
    let info = UserInfo.info!
    /** 포인트 사용하기*/
    func usePoint(point:Int,complete:@escaping(_ sucess:Bool)->Void) {
        info.addPoint(point: -point) { (sucess) in
            if sucess {
                DispatchQueue.main.async {
                    let msg = String(format:"%@ point used\nexp get : %@\nexp : %@\nlevel : %@".localized
                        ,point.decimalForamtString
                        ,point.decimalForamtString
                        ,UserInfo.info?.exp.decimalForamtString ?? "0"
                        ,((UserInfo.info?.level ?? 0)+1).decimalForamtString)
                    Toast.makeToast(message: msg)
                }
            }
            complete(sucess)
        }
    }
    /** 포인트 더하기*/
    func addPoint(point:Int,complete:@escaping(_ sucess:Bool)->Void) {
        info.addPoint(point: point, complete: complete)
    }
}
