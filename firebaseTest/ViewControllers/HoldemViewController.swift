//
//  HoldemViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
class HoldemViewController : UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var myPointTitleLabel: UILabel!
    @IBOutlet weak var myPointLabel: UILabel!
    @IBOutlet weak var myBettingTitleLabel: UILabel!
    @IBOutlet weak var myBettingLabel: UILabel!
    @IBOutlet weak var gamePlayButton: UIButton!
    static var viewController : HoldemViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "holdem") as! HoldemViewController
    }
    @IBOutlet weak var holdemView:HoldemView!
    enum GameState:String {
        /** 대기중*/
        case wait = "Holdem"
        /** 각 플레이어가 2장씩 카드 받음*/
        case preflop = "preflop"
        /** 바닥에 커뮤니티 카드 3장 오픈*/
        case flop = "flop"
        /** 4번째 커뮤니티 카드 오픈*/
        case turn = "turn"
        /** 5번째 커뮤니티 카드 오픈*/
        case river = "river"
    }
    
    var gameState:GameState = .wait
    var bettingPoint:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        holdemView.dealerCards = GameManager.shared.popCards(number: 2)
        holdemView.myCards = GameManager.shared.popCards(number: 2)
        holdemView.communityCards = GameManager.shared.popCards(number: 5)
        
        let closeBtnImage =
            #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))//.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeBtnImage.withTintColor(.autoColor_text_color), for: .normal)
        closeButton.setImage(closeBtnImage.withTintColor(.autoColor_weak_text_color), for: .highlighted)
        
        loadData()
        setTitle()
    }
    
    private func setTitle() {
        titleLabel.text = gameState.rawValue.localized
        switch gameState {
        case .wait:
            gamePlayButton.setTitle("playGame".localized, for: .normal)
        case .preflop:
            gamePlayButton.setTitle("continue".localized, for: .normal)
        case .flop,.turn:
            closeButton.isEnabled = false
            gamePlayButton.setTitle("betting".localized, for: .normal)
        case .river:
            closeButton.isEnabled = false
            gamePlayButton.setTitle("continue".localized, for: .normal)
        }
    }
    private func loadData() {
        myPointLabel.text = UserInfo.info?.point.decimalForamtString
        myBettingLabel.text = bettingPoint.decimalForamtString
    }
    
    @IBAction func onTouchupCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    @IBAction func onTouchupButton(_ sender: Any) {
        switch gameState {
        case .wait:
            holdemView.showMyCard()
            gameState = .preflop
        case .preflop:
            holdemView.showCommunityCard(number: 3)
            gameState = .flop
        case .flop:
            holdemView.showCommunityCard(number: 4)
            gameState = .turn
        case .turn:
            holdemView.showCommunityCard(number: 5)
            gameState = .river
        case .river:
            holdemView.showDealerCard()
            dismiss(animated: true, completion: nil)
            break
        }
        setTitle()
    }
}

