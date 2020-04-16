//
//  LightBodImage+Extensions.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import Lightbox

extension LightboxImage {
    static func getImages(imageUrls:[URL])->[LightboxImage] {
        var result:[LightboxImage] = []
        for url in imageUrls {
            result.append(LightboxImage(imageURL: url))
        }
        return result
    }
}

