//
//  HoldemView.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

class HoldemView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var dealersCardImageViews:[UIImageView]!
    @IBOutlet var communityCardImageViews:[UIImageView]!
    @IBOutlet var myCardImageViews:[UIImageView]!
    @IBOutlet var dealarSelectionViews:[UIImageView]!
    @IBOutlet var mySelectionViews:[UIImageView]!
    var dealerCards:[Card] = []
    var myCards:[Card] = []
    var communityCards:[Card] = []
    
    var bettingPint:Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
    
    func insertCard() {
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
    
    func showDealerCard() {
        if dealerCards.count == 2 {
            for (index, card) in dealerCards.enumerated() {
                dealersCardImageViews[index].image = card.image
            }
        }
    }
    
    func showCommunityCard(number:Int) {
        if number > 5 || number == 0 {
            return
        }
        for i in 0..<number {
            communityCardImageViews[i].image = communityCards[i].image
        }
    }
    
    func makeValuesSet() {
        
    }
}
