//
//  HoldemView.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
//@IBDesignable
class HoldemView: UIView {
    @IBInspectable public var cornerRadius:CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBOutlet var contentView: UIView!
    @IBOutlet var dealersCardImageViews:[UIImageView]!
    @IBOutlet var communityCardImageViews:[UIImageView]!
    @IBOutlet var myCardImageViews:[UIImageView]!
    
    var dealerCards:[Card] = []
    var myCards:[Card] = []
    var communityCards:[Card] = []
    
    var bettingPint:Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func prepareForInterfaceBuilder() {
        contentView.layer.borderColor = UIColor.text_color.cgColor
        contentView.layer.borderWidth = 1
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
}
