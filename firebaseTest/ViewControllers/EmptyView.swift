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
        case wait
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
        label.textColor = .autoColor_text_color
        button.setTitleColor(.autoColor_bold_text_color, for: .normal)
        button.setTitleColor(.autoColor_text_color, for: .highlighted)
        setTitle()
    }
    
    func setTitle() {
        switch type {
        case .wait:
            imageView.image = nil
            label.text = "Waiting for server to respond.".localized
            button.isHidden = true
        case .empty:
            if #available(iOS 13.0, *) {
                imageView.image = #imageLiteral(resourceName: "dentist-mask").withRenderingMode(.alwaysTemplate).withTintColor(.autoColor_bold_text_color)
            } else {
                imageView.image = #imageLiteral(resourceName: "dentist-mask").withRenderingMode(.alwaysTemplate)
                // Fallback on earlier versions
            }
            label.text = "There are no public mask vendors nearby.".localized
            button.setTitle("retry".localized, for: .normal)
            button.isHidden = false
            
        case .locationNotAllow:
            if #available(iOS 13.0, *) {
                imageView.image = #imageLiteral(resourceName: "location").withRenderingMode(.alwaysTemplate).withTintColor(.autoColor_bold_text_color)
            } else {
                imageView.image = #imageLiteral(resourceName: "location").withRenderingMode(.alwaysTemplate)
            }
            label.text = "Location information access is required.\nPlease make your location accessible.".localized
            button.setTitle("Setting up".localized, for: .normal)
            button.isHidden = false
        }
    }
    
    @IBAction func onTouchupButton(_ sender : UIButton) {
        delegate?.onTouchupButton(viewType: self.type)
    }
}
