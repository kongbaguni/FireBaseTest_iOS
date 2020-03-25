//
//  GoogleADViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/13.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import GoogleMobileAds
class GoogleAd : NSObject {
    private var complete:(_ sucess:Bool)->Void = {_ in }
    
    var rewardAD:GADRewardedAd? = nil

    var isSucess:Bool = false
        
    func showAd(targetViewController:UIViewController, complete:@escaping(_ sucess:Bool)->Void) {
        rewardAD = GADRewardedAd(adUnitID: Consts.GADID)
        isSucess = false
        self.complete = complete
        rewardAD?.load(GADRequest()) { (error) in
            if self.rewardAD?.isReady == true {
                self.rewardAD?.present(fromRootViewController: targetViewController, delegate: self)
            }
        }
    }
        
}

extension GoogleAd : GADRewardedAdDelegate {
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        isSucess = true
    }
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        UserInfo.info?.updateForRanking(type: .count_of_ad, addValue: 1, complete: { [weak self](sucess) in
            if sucess {
                self?.complete(self?.isSucess ?? false)
            }
            else {
                self?.complete(false)
            }
        })
    }
}
