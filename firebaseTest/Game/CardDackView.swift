//
//  CardDackView.swift
//  PokerTest
//
//  Created by Changyul Seo on 2019/11/08.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift

class CardDackView : UIView {
    var isNeedDisplayPlayerName:Bool = false
    @IBOutlet weak var contentView:UIView!
    @IBOutlet var cardsDack1Set:[UIImageView]!
    @IBOutlet var cardsDack2Set:[UIImageView]!
       
    @IBOutlet weak var dealerValueLabel: UILabel!
    @IBOutlet weak var myValueLabel: UILabel!
    
    @IBOutlet weak var gameResultLabel: UILabel!
    
    var delarCards:CardSet? = nil {
        didSet {
            let imageViews = cardsDack1Set
            for (index,card) in (delarCards?.cards ?? []).enumerated() {
                imageViews?[index].image = card.image
            }
            dealerValueLabel.text = "\(delarCards?.cardValue.stringValue ?? "") \(delarCards?.point.decimalForamtString ?? "")"            
        }
    }
    
    var myCards:CardSet? = nil {
        didSet {
            let imageViews = cardsDack2Set
            for (index,card) in (myCards?.cards ?? []).enumerated() {
                imageViews?[index].image = card.image
            }
            myValueLabel.text = "\(myCards?.cardValue.stringValue ?? "") \(myCards?.point.decimalForamtString ?? "")"
        }
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
        Bundle.main.loadNibNamed("CardDackView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setDefaultImage()
        myValueLabel.text = nil
        dealerValueLabel.text = nil
        gameResultLabel.text = nil
    }
    
    private func setDefaultImage() {
        for set in [cardsDack1Set, cardsDack2Set] {
            if let s = set {
                for view in s {
                    view.image = #imageLiteral(resourceName: "blue_back")
                }
            }
        }
    }
    
     

}
