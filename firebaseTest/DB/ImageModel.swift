//
//  ImageModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/26.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class ImageModel: Object {
    enum ImageType : CaseIterable {
        case talk
        case review
        case profile
    }

    @objc dynamic var thumbURLstr:String = ""
    @objc dynamic var largeURLstr:String = ""
    
    override static func primaryKey() -> String? {
        return "thumbURLstr"
    }
}

extension ImageModel {
    var thumbURL:URL? {
        return URL(string: thumbURLstr)
    }
    var largeURL:URL? {
        return URL(string: largeURLstr)
    }
}

extension ImageModel {
    static func upload(url:URL,type:ImageModel.ImageType,uploadURL:String,complete:@escaping(_ imageURL:String?)->Void) {
        guard let data = try? Data(contentsOf: url) , let image = UIImage(data: data) else {
            complete(nil)
            return
        }
        var thumbMaxSize:CGSize {
            switch type {
            case .profile:
                return Consts.PROFILE_THUMB_SIZE
            case .review:
                return Consts.REVIEW_THUMB_MAX_SIZE
            case .talk:
                return Consts.TALK_THUMB_MAX_SIZE
            }
        }
        let thumbSize = image.size.resize(target: thumbMaxSize, isFit: true)
        guard let thumbImageURL = image.kf.resize(to: thumbSize).save(name: "uploadThumbTemp") else {
            complete(nil)
            return
        }
        
        FirebaseStorageHelper().uploadImage(url: thumbImageURL, contentType: "image/jpeg", uploadURL: "\(uploadURL)_thumb") { (thumbUrl) in
            FirebaseStorageHelper().uploadImage(url: url, contentType: "image/jpeg", uploadURL: uploadURL) { (largeUrl) in
                if let t = thumbUrl, let l = largeUrl {
                    let data = [
                        "thumbURLstr":t.absoluteString,
                        "largeURLstr":l.absoluteString
                    ]
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.create(ImageModel.self, value: data, update: .all)
                    try! realm.commitWrite()
                    complete(t.absoluteString)
                } else {
                    complete(nil)
                }
            }
        }
    }
    
    static func imageWithThumbURL(url:String)->ImageModel? {
        return try! Realm().object(ofType: ImageModel.self, forPrimaryKey: url)
    }
    
    static func imagesWithThumbURLS(urls:[String])->Set<ImageModel> {
        var result = Set<ImageModel>()
        for url in urls {
            if let img = ImageModel.imageWithThumbURL(url: url) {
                result.insert(img)
            }
        }
        return result
    }
}
