//
//  Toast.swift
//  test
//
//  Created by 서창열 on 2019/10/23.
//  Copyright © 2019 서창열. All rights reserved.
//

import Toast_Swift

struct Toast {
    static func makeToast(message:String, image:UIImage? = nil ,duration:TimeInterval = 5) {
        guard let view = UIApplication.shared.lastViewController?.view else {
            return
        }
        view.hideToast()
        
        var toastStyle:ToastStyle {
            let isWhite = UIApplication.shared.isDarkMode
            var style = ToastStyle()
            style.backgroundColor = isWhite ? UIColor(white: 1, alpha: 0.9) : UIColor(white: 0, alpha: 0.9)
            style.titleColor = .red
            style.messageColor =  isWhite ? .black : .white
            //ToastManager.shared.style = style
            return style
        }
        
        let top = CGPoint(x: UIScreen.main.bounds.width/2, y: 100)
        view.makeToast(message, duration: duration, point: top, title: nil, image: image, style: toastStyle, completion: nil)
    }
}
