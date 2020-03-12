//
//  EmptyView.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/12.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
protocol EmptyViewDelegate : class {
    func onTouchupButton(viewType:EmptyView.ViewType)
}

class EmptyView: UIView {
    enum ViewType {
        case locationNotAllow
        case empty
    }
    
    var type:ViewType = .empty {
        didSet {
            setTitle()
        }
    }
    
    weak var delegate:EmptyViewDelegate? = nil
    
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var button:UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.textColor = .text_color
        button.setTitleColor(.bold_text_color, for: .normal)
        button.setTitleColor(.text_color, for: .highlighted)
        setTitle()
    }
    
    func setTitle() {
        switch type {
        case .empty:
            imageView.image = #imageLiteral(resourceName: "dentist-mask").withRenderingMode(.alwaysTemplate).withTintColor(.bold_text_color)
            label.text = "There are no public mask vendors nearby.".localized
            button.setTitle("retry".localized, for: .normal)
            
        case .locationNotAllow:
            imageView.image = #imageLiteral(resourceName: "location").withRenderingMode(.alwaysTemplate).withTintColor(.bold_text_color)
            label.text = "Location information access is required.\nPlease make your location accessible.".localized
            button.setTitle("Setting up".localized, for: .normal)
        }
    }
    
    @IBAction func onTouchupButton(_ sender : UIButton) {
        delegate?.onTouchupButton(viewType: self.type)
    }
}
