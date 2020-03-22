//
//  Loading.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

fileprivate let tag = 881122

class Loading {
    fileprivate weak var indicator:NVActivityIndicatorView? = nil
    
    func show(viewController:UIViewController) {
        guard let view = viewController.view else {
            return
        }
        if let indicator = view.viewWithTag(tag) as? NVActivityIndicatorView {
            indicator.startAnimating()
        } else {
            let indicator = NVActivityIndicatorView(
                frame: CGRect(x: UIScreen.main.bounds.width/2 - 25,
                              y: UIScreen.main.bounds.height/2 - 25,
                              width: 50, height: 50),
                type: .ballRotateChase,
                color: .autoColor_indicator_color,
                padding: 0)
            view.addSubview(indicator)
            view.tag = tag
            indicator.startAnimating()
            self.indicator = indicator
        }
        
    }
    
    func hide() {
        self.indicator?.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.indicator?.removeFromSuperview()
        }
    }
}
