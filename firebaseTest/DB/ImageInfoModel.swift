//
//  ImageInfoModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/04/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class ImageInfoModel: Object {
    @objc dynamic var url:String = ""
    @objc dynamic var width:Float = 0
    @objc dynamic var height:Float = 0
    
    var size:CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    override static func primaryKey() -> String? {
        return "url"
    }
    
    static func create(url:String?, size:CGSize?) {
        if let url = url, let size = size {
            let data:[String:Any] = [
                "url" : url,
                "width" : size.width,
                "height" : size.height
            ]
            let id = url.sha512
            FS.store.collection(FSCollectionName.IMAGE_INFO).document(id).setData(data) { (error) in
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(ImageInfoModel.self, value: data, update: .all)
                try! realm.commitWrite()
            }
        }
    }
    
    static func getSize(url:String?) -> CGSize? {
        if let url = url {
            if let model = try! Realm().object(ofType: ImageInfoModel.self, forPrimaryKey: url) {
                return model.size
            }
        }
        return nil
    }
    
    static func getSize(url:String?, getSize:@escaping(_ size:CGSize?)->Void) {
        guard let url = url else {
            getSize(nil)
            return
        }
        FS.store.collection(FSCollectionName.IMAGE_INFO).document(url.sha512).getDocument { (snapShot, error) in
            if let data = snapShot {
                if let d = data.data() {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let model = realm.create(ImageInfoModel.self, value: d, update: .all)
                    try! realm.commitWrite()
                    getSize(model.size)
                    return
                }
            }
            getSize(nil)
        }
    }
}
