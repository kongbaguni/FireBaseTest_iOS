//
//  HoldemView.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

class HoldemView: UIView {
    struct Set {
        let cardSet:CardSet
        let selectIndex:[Int]
        
        /** 소트 위한 비교 self 가 높으면 true 리턴*/
        func compare(set:Set) -> Bool {
            if cardSet.cardValue.rawValue > set.cardSet.cardValue.rawValue {
                return true
            } else if cardSet.cardValue == set.cardSet.cardValue {
                return cardSet.point > set.cardSet.point
            }
            return false
        }
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet var dealersCardImageViews:[UIImageView]!
    @IBOutlet var communityCardImageViews:[UIImageView]!
    @IBOutlet var myCardImageViews:[UIImageView]!
    @IBOutlet var dealarSelectionViews:[UIImageView]!
    @IBOutlet var mySelectionViews:[UIImageView]!
    
    @IBOutlet weak var dealarGameValueLabel: UILabel!
    @IBOutlet weak var dealarBettingLabel: UILabel!
    
    @IBOutlet weak var myBettingLabel: UILabel!
    @IBOutlet weak var myGameValueLabel: UILabel!
    
    var dealerCards:[Card] = []
    var myCards:[Card] = []
    var communityCards:[Card] = []
    
    var dealarBetting:Int = 0 {
        didSet {
            dealarBettingLabel?.text = dealarBetting.decimalForamtString
        }
    }
    var bettingPoint:Int = 0 {
        didSet {
            myBettingLabel?.text = bettingPoint.decimalForamtString
        }
    }

    /** 딜러의 족보 저장*/
    var dealarsBestCardSet:Set? = nil {
        didSet {
            if let value = dealarsBestCardSet {
                dealarGameValueLabel.text = "\(value.cardSet.cardValue.stringValue.localized) \(value.cardSet.point)"
            }
        }
    }
    
    /** 내 족보 저장*/
    var myBestCardSet:Set? = nil {
        didSet {
            if let value = myBestCardSet {
                myGameValueLabel.text = "\(value.cardSet.cardValue.stringValue.localized) \(value.cardSet.point)"
            }
        }
    }

    /** 게임결과 리턴*/
    var gameResult:CardSet.GameResult? {
        if isShowDealarCard == false {
            return nil
        }
        if let dset = dealarsBestCardSet?.cardSet , let mset = myBestCardSet?.cardSet {
            return mset.getGameResult(targetCardSet: dset)
        }
        return nil
    }
    
            
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        //  fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("HoldemView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.autoColor_text_color.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .autoColor_bg_color
    }
    /** 게임 초기화 카드 분배*/
    func insertCard() {
        bettingPoint = 0
        dealarBetting = 0
        isShowDealarCard = false
        dealarGameValueLabel.isHidden = true
        myGameValueLabel.isHidden = true
        GameManager.shared.shuffleLinit = 9
        dealerCards = GameManager.shared.popCards(number: 2)
        myCards = GameManager.shared.popCards(number: 2)
        communityCards = GameManager.shared.popCards(number: 5)
        for set:[UIImageView] in [dealersCardImageViews, communityCardImageViews, myCardImageViews] {
            for view:UIImageView in set {
                view.image = #imageLiteral(resourceName: "gray_back")
            }
        }
        for set:[UIImageView] in [dealarSelectionViews, mySelectionViews] {
            for view:UIImageView in set {
                view.isHidden = true
            }
        }
    }
    
    func showMyCard() {
        if myCards.count == 2 {
            for (index, card) in myCards.enumerated() {
                myCardImageViews[index].image = card.image
            }
        }
    }
    
    var isShowDealarCard:Bool = false
    func showDealerCard() {
        isShowDealarCard = true
        dealarGameValueLabel.isHidden = false
        if dealerCards.count == 2 {
            for (index, card) in dealerCards.enumerated() {
                dealersCardImageViews[index].image = card.image
            }
        }
    }
    
    func showCommunityCard(number:Int) {
        myGameValueLabel.isHidden = false
        if number > 5 || number == 0 {
            return
        }
        for i in 0..<number {
            communityCardImageViews[i].image = communityCards[i].image
        }
        makeValuesSet(openComunitiCardNumber: number)
    }
    
    func makeValuesSet(openComunitiCardNumber:Int) {
        if communityCards.count != 5 {
            return
        }
        var mySet:[Set] = []
        var dealarSet:[Set] = []
        
        var list:[[Int]] {
            switch openComunitiCardNumber {
            case 3:
                return [[0,1,2]]
            case 4:
                return [[0,1,2],[0,1,3],[1,2,3]]
            case 5:
                return [[0,1,2],[0,1,3],[0,1,4],[0,2,3],[0,2,4],[0,3,4],[1,2,3],[1,3,4],[2,3,4]]
            default:
                return []
            }
        }
        
        for set in list {
            var mycards = myCards
            var dealarCards = dealerCards
            for index in set {
                mycards.append(communityCards[index])
                dealarCards.append(communityCards[index])
            }
            mySet.append(Set(cardSet: CardSet(cards: mycards),selectIndex: set))
            dealarSet.append(Set(cardSet: CardSet(cards: dealarCards),selectIndex: set))
        }

        
        mySet.sort { (a, b) -> Bool in
            return a.compare(set: b)
        }
        
        dealarSet.sort { (a, b) -> Bool in
            return a.compare(set: b)
        }
        
        guard let myCardSet = mySet.first, let dealarCardSet = dealarSet.first else {
            return
        }
        let gameResult = myCardSet.cardSet.getGameResult(targetCardSet: dealarCardSet.cardSet)
        for set:[UIImageView] in [mySelectionViews, dealarSelectionViews] {
            for view:UIImageView in set {
                view.isHidden = true
            }
        }
        for idx in myCardSet.selectIndex {
            mySelectionViews[idx].isHidden = false
        }
        for idx in dealarCardSet.selectIndex {
            dealarSelectionViews[idx].isHidden = false
        }

        for view in communityCardImageViews {
            view.alpha = 0.5
        }
        for idx in myCardSet.selectIndex {
            communityCardImageViews[idx].alpha = 1
        }
        
        myBestCardSet = myCardSet
        dealarsBestCardSet = dealarCardSet

        print(gameResult)
    }
}
