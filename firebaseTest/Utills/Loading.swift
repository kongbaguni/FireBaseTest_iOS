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

struct Loading {
    static func show(viewController:UIViewController) {
        guard let view = viewController.view else {
            return
        }
        if let indicator = view.viewWithTag(tag) as? NVActivityIndicatorView {
            indicator.startAnimating()
        } else {
            let indicator = NVActivityIndicatorView(
                frame: UIScreen.main.bounds,
                type: .ballRotateChase,
                color: .autoColor_indicator_color,
                padding: UIScreen.main.bounds.width)
            view.addSubview(indicator)
            view.tag = tag
            indicator.startAnimating()
        }
    }
    
    static func hide(viewController:UIViewController) {
        guard let view = viewController.view else {
            return
        }
        if let indicator = view.viewWithTag(tag) as? NVActivityIndicatorView {
            indicator.stopAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                indicator.removeFromSuperview()
            }
        }
    }
}
