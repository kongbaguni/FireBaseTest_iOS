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
    let dealar = Dealar()
    
    var dealerCards:[Card] = []
    var myCards:[Card] = []
    var communityCards:[Card] = [] {
        didSet {
            for view in communityCardImageViews {
                view.isHidden = true
            }
            for (index, _) in communityCards.enumerated() {
                communityCardImageViews[index].isHidden = false
            }
        }
    }
    
    var dealarBetting:Int = 0 {
        didSet {
            dealarBettingLabel?.isHidden = dealarBetting == 0
            dealarBettingLabel?.text = "\("betting".localized) : \(dealarBetting.decimalForamtString)"
        }
    }
    var bettingPoint:Int = 0 {
        didSet {
            myBettingLabel?.isHidden = bettingPoint == 0
            myBettingLabel?.text =  "\("betting".localized) : \(bettingPoint.decimalForamtString)"
        }
    }

    /** 딜러의 족보 저장*/
    var dealarsBestCardSet:Set? = nil {
        didSet {
            if let value = dealarsBestCardSet {
                dealarGameValueLabel.text = "\(value.cardSet.cardValue.stringValue.localized) \(value.cardSet.point)"
            }
            dealar.cardSet = dealarsBestCardSet?.cardSet
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
    
    /** 포스팅 위한 게임결과 리턴*/
    var holdemResult:HoldemResult? {        
        if let result = gameResult,
            let dealarBestCard = dealarsBestCardSet,
            let myBestCard = myBestCardSet
            {
            let c = communityCards
            return HoldemResult(
                dealarHandCards: [dealerCards[0].stringValue,dealerCards[1].stringValue],
                playerHandCards: [myCards[0].stringValue,myCards[1].stringValue],
                communityCards: [c[0].stringValue, c[1].stringValue, c[2].stringValue, c[3].stringValue, c[4].stringValue],
                dealarsCommunityCardSelect: dealarBestCard.selectIndex,
                playersCommunityCardSelect: myBestCard.selectIndex,
                dealarsValue: "\(dealarBestCard.cardSet.stringValue.localized) \(dealarBestCard.cardSet.point)",
                playersValue: "\(myBestCard.cardSet.stringValue.localized) \(myBestCard.cardSet.point)",
                dealarsBetting: dealarBetting,
                playersBetting: bettingPoint,
                gameResult: result)
        }
        return nil
    }
        
    func showSelection(selection:[Int],isPlayer:Bool) {
        if isPlayer {
            for view in communityCardImageViews {
                if view.image != #imageLiteral(resourceName: "gray_back") {
                    view.alpha = 0.5
                } else {
                    view.alpha = 1
                }
            }
            for idx in selection {
                communityCardImageViews[idx].alpha = 1
            }
            for view in mySelectionViews {
                view.isHidden = true
            }
            for idx in selection {
                mySelectionViews[idx].isHidden = false
            }
        }
        else {
            for view in dealarSelectionViews {
                view.isHidden = true
            }
            for idx in selection {
                dealarSelectionViews[idx].isHidden = false
            }

        }
    }
    /** 게임 결과 세팅 (결과만 보여주기 용)*/
    func setDataWithHoldemResult(result:HoldemResult?) {
        guard let result = result else {
            return
        }
        isOnlyGameResult = true
        
        dealerCards.removeAll()
        myCards.removeAll()
        communityCards.removeAll()
        for d in result.dealarHandCards {
            if let card = Card.makeCardWithString(string: d) {
                dealerCards.append(card)
            }
        }
        
        for c in result.communityCards {
            if let card = Card.makeCardWithString(string: c) {
                communityCards.append(card)
            }
        }
        
        for m in result.playerHandCards {
            if let card = Card.makeCardWithString(string: m) {
                myCards.append(card)
            }
        }
        isShowDealarCard = true
        dealarBetting = result.dealarsBetting
        bettingPoint = result.playersBetting
        showSelection(selection: result.playersCommunityCardSelect, isPlayer: true)
        showSelection(selection: result.dealarsCommunityCardSelect, isPlayer: false)
        dealarBettingLabel.text = "\("betting".localized) : \(result.dealarsBetting.decimalForamtString)"
        showMyCard()
        showDealerCard()
        showCommunityCard(number: 5)
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
        communityCards = GameManager.shared.popCards(number: 3)
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
        for view in communityCardImageViews {
            view.alpha = 1
        }
    }
    
    func insertTurnRiver(getCard:@escaping(_ card:Card)->Void) {
        _ = GameManager.shared.popCards(number: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            let cards = GameManager.shared.popCards(number: 1)
            getCard(cards.first!)
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
        if number > 5 || number == 0 || communityCards.count < number{
            return
        }
        for i in 0..<number {
            communityCardImageViews[i].image = communityCards[i].image
        }
        makeValuesSet(openComunitiCardNumber: number)
        switch number {
        case 3,4:
            dealarBetting += dealar.bettingPoint
        default:
            break
        }
    }
    
    func makeValuesSet(openComunitiCardNumber:Int) {
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
        showSelection(selection: myCardSet.selectIndex, isPlayer: true)
        showSelection(selection: dealarCardSet.selectIndex, isPlayer: false)
        
        myBestCardSet = myCardSet
        dealarsBestCardSet = dealarCardSet

        print(gameResult)
    }
    var isOnlyGameResult = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isOnlyGameResult {
            contentView.layer.cornerRadius = 0
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.borderWidth = 0
            contentView.layer.masksToBounds = false
            contentView.backgroundColor = UIColor.clear                
        } else {
            contentView.layer.cornerRadius = 10
            contentView.layer.borderColor = UIColor.autoColor_text_color.cgColor
            contentView.layer.borderWidth = 1
            contentView.layer.masksToBounds = true
            contentView.backgroundColor = .autoColor_bg_color
        }
        for view in [dealarBettingLabel, myBettingLabel] {
            view?.textColor = .autoColor_weak_text_color
        }
        for view in mySelectionViews {
            view.image = #imageLiteral(resourceName: "point").withTintColor(.autoColor_bold_text_color)
            view.alpha = 0.5
        }
        for view in dealarSelectionViews {
            view.image = #imageLiteral(resourceName: "point").withTintColor(.autoColor_text_color)
            view.alpha = 0.5
        }
    }
}


struct HoldemResult {
    let dealarHandCards:[String]
    let playerHandCards:[String]
    let communityCards:[String]
    let dealarsCommunityCardSelect:[Int]
    let playersCommunityCardSelect:[Int]
    let dealarsValue:String
    let playersValue:String
    let dealarsBetting:Int
    let playersBetting:Int
    let gameResult:CardSet.GameResult
    static func makeResult(base64EncodedString:String)->HoldemResult? {
        if let data = Data(base64Encoded: base64EncodedString) {
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                let dealarHandCards = json["dealarHandCards"] as? [String] ?? []
                let playerHandCards = json["playerHandCards"] as? [String] ?? []
                let communityCards = json["communityCards"] as? [String] ?? []
                let dealarsCommunityCardSelect = json["dealarsCommunityCardSelect"] as? [Int] ?? []
                let playersCommunityCardSelect = json["playersCommunityCardSelect"] as? [Int] ?? []
                let dealarsValue = json["dealarsValue"] as? String ?? ""
                let playersValue = json["playersValue"] as? String ?? ""
                let dealarsBetting = json["dealarsBetting"] as? Int ?? 0
                let playersBetting = json["playersBetting"] as? Int ?? 0
                let gameResult = CardSet.GameResult(rawValue: json["gameResult"] as? String ?? "") ?? .tie
                return HoldemResult(
                    dealarHandCards: dealarHandCards,
                    playerHandCards: playerHandCards,
                    communityCards: communityCards,
                    dealarsCommunityCardSelect: dealarsCommunityCardSelect,
                    playersCommunityCardSelect: playersCommunityCardSelect,
                    dealarsValue: dealarsValue,
                    playersValue: playersValue,
                    dealarsBetting: dealarsBetting,
                    playersBetting: playersBetting,
                    gameResult: gameResult)
            }
        }
        return nil
    }
    
    var jsonBase64EncodedString:String? {
        let data:[String:Any] = [
            "dealarHandCards":dealarHandCards,
            "playerHandCards":playerHandCards,
            "communityCards":communityCards,
            "dealarsCommunityCardSelect":dealarsCommunityCardSelect,
            "playersCommunityCardSelect":playersCommunityCardSelect,
            "dealarsValue":dealarsValue,
            "playersValue":playersValue,
            "playersBetting":playersBetting,
            "dealarsBetting":dealarsBetting,
            "gameResult":gameResult.rawValue
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        return jsonData?.base64EncodedString()
    }
}
