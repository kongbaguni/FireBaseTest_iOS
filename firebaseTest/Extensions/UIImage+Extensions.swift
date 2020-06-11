//
//  UIImage+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/27.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit

extension UIImage {
    open class var placeHolder_image:UIImage {
        return #imageLiteral(resourceName: "placeholder")
    }
    open class var placeHolder_profile:UIImage {        
        return #imageLiteral(resourceName: "profile")
    }
    
    open class var closeBtnImage_normal:UIImage {
        if #available(iOS 13.0, *) {
            return #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
                    .withTintColor(.autoColor_text_color)
        } else {
            return #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        }
    }
    
    open class var closeBtnImage_highlighted:UIImage {
        if #available(iOS 13.0, *) {
            return #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
                    .withTintColor(.autoColor_weak_text_color)
        } else {
            return #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        }
    }

    open class var myBubble:UIImage {#imageLiteral(resourceName: "myBubble")}
    
    open class var bubble:UIImage {#imageLiteral(resourceName: "bubble")}
    
    open class var bubble_bottom:UIImage {#imageLiteral(resourceName: "bubble_bottom")}
}


extension UIImage {
    func save(name:String)->URL? {
        guard let imageData = pngData() else {
            return nil
        }
        do {
            let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(name)
            try? FileManager.default.removeItem(at: imageURL)
            try imageData.write(to: imageURL)
            return imageURL
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
}
