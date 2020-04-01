//
//  ReviewModel.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/31.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import FirebaseStorage
import FirebaseFirestore
extension Notification.Name {
    static let reviewWriteNotification = Notification.Name("reviewWriteNotification_observer")
    static let reviewEditNotification = Notification.Name("reviewEditNotification_observer")
}

class ReviewModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var creatorId:String = ""
    @objc dynamic var lat:Double = 0
    @objc dynamic var lng:Double = 0
    @objc dynamic var name:String = ""
    @objc dynamic var starPoint:Int = 0
    @objc dynamic var comment:String = ""
    @objc dynamic var price:Int = 0
    @objc dynamic var photoUrls:String = ""
    @objc dynamic var likeCount:Int = 0
    @objc dynamic var regTimeIntervalSince1970:Double = 0
    @objc dynamic var modifiedTimeIntervalSince1970:Double = 0
    let editList = List<ReviewEditModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["creatorId"]
    }
}

class ReviewEditModel : Object {
    @objc dynamic var id:String = ""
    @objc dynamic var lat:Double = 0
    @objc dynamic var lng:Double = 0
    @objc dynamic var name:String = ""
    @objc dynamic var starPoint:Int = 0
    @objc dynamic var comment:String = ""
    @objc dynamic var price:Int = 0
    @objc dynamic var photoUrls:String = ""
    @objc dynamic var regTimeIntervalSince1970:Double = 0
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension ReviewModel {
    var location:CLLocationCoordinate2D? {
        if lat == 0 && lng == 0 {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    var photoUrlList:[URL] {
        var result:[URL] = []
        for str in photoUrls.components(separatedBy: ",") {
            if let url = URL(string: str) {
                result.append (url)
            }
        }
        return result
    }
}

extension ReviewModel {
    fileprivate static func uploadImages(documentId:String,photos:[Data], complete:@escaping(_ uploadUrls:[String]?)->Void) {
        guard let creatorId = UserInfo.info?.id else {
            complete(nil)
            return
        }
        if photos.count == 0 {
            complete([])
            return
        }
        var photolist = photos
        var uploadUrls:[String] = []
        let st = FirebaseStorageHelper()
        func upload() {
            if photolist.count == 0 {
                complete(uploadUrls)
                return
            }
            if let data = photolist.first {
                st.uploadImage(withData: data, contentType: "image/jpeg", uploadURL: "\(FSCollectionName.STORAGE_REVIEW_IMAGE)/\(creatorId)/\(documentId)/\(UUID().uuidString).jpg") { (url) in
                    if let url = url {
                        photolist.removeFirst()
                        uploadUrls.append(url.absoluteString)
                        upload()
                    } else {
                        complete(nil)
                    }
                }
            }
        }
        
        upload()
    }
    
    static func createReview(name:String,starPoint:Int,comment:String,price:Int,photos:[Data],complete:@escaping(_ isSucess:Bool)->Void) {
        guard let creatorId = UserInfo.info?.id else {
            complete(false)
            return
        }
        
        let now = Date().timeIntervalSince1970
        let id = "\(creatorId)_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"

        func write(uploadImages:[String]) {
            var data:[String:Any] = [
                "id":id,
                "creatorId":creatorId,
                "name":name,
                "starPoint":starPoint,
                "comment":comment,
                "price":price,
                "regTimeIntervalSince1970": now,
                "modifiedTimeIntervalSince1970": now,
                "lat":UserDefaults.standard.lastMyCoordinate?.latitude ?? 0,
                "lng":UserDefaults.standard.lastMyCoordinate?.longitude ?? 0
            ]
            if uploadImages.count > 0 {
                data["photoUrls"] = uploadImages.stringValue
            }
            let doc = Firestore.firestore().collection(FSCollectionName.REVIEW).document(id)
            doc.setData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let model = realm.create(ReviewModel.self, value: data, update: .all)
                    try! realm.commitWrite()
                    model.edit(name: nil, starPoint: nil, comment: nil, price: nil, addphotos: [], deletePhotos: []) { (sucess) in
                        complete(sucess)
                        NotificationCenter.default.post(name: .reviewWriteNotification, object: model.id)
                    }
                } else {
                    complete(false)
                }
            }
        }
        
        uploadImages(documentId: id ,photos: photos) { (urls) in
            if let uploadImages = urls {
                write(uploadImages: uploadImages)
            }
        }
        
    }
    
    func edit(name:String?,starPoint:Int?,comment:String?,price:Int?,addphotos:[Data],deletePhotos:[String],complete:@escaping(_ isSucess:Bool)->Void) {
        let editId = "\(creatorId)_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
        let docId = id
        func update(addPhotoUrls:[String]) {
            var data:[String:Any] = [
                "id" : editId,
                "lat" : UserDefaults.standard.lastMyCoordinate?.latitude ?? 0,
                "lng" : UserDefaults.standard.lastMyCoordinate?.longitude ?? 0,
                "name" : name ?? self.name,
                "starPoint" : starPoint ?? self.starPoint,
                "comment" : comment ?? self.comment,
                "price" : price ?? self.price,
                "modifiedTimeIntervalSince1970" : Date().timeIntervalSince1970
            ]
            
            var images = Set<String>(photoUrls.components(separatedBy: ","))
            if deletePhotos.count > 0 {
                images.subtract(Set<String>(deletePhotos))
            }
            for item in addPhotoUrls {
                images.insert(item)
            }
            data["photoUrls"] = images.stringValue
            
            let document = Firestore.firestore().collection(FSCollectionName.REVIEW).document(id)
            document.collection("edit").document(editId).setData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let model = realm.create(ReviewEditModel.self, value: data, update: .all)
                    if let doc = realm.object(ofType: ReviewModel.self, forPrimaryKey: docId) {
                        doc.editList.append(model)
                    }
                    if name != nil || starPoint != nil || comment != nil || price != nil || addphotos.count > 0 || deletePhotos.count > 0 {
                        data["id"] = docId
                        realm.create(ReviewModel.self, value: data, update: .modified)
                    }
                    try! realm.commitWrite()
                    NotificationCenter.default.post(name: .reviewEditNotification, object: docId)
                }
                complete(error == nil)
            }
        }
        
        ReviewModel.uploadImages(documentId:self.id ,photos: addphotos) { (urls) in
            if let list = urls {
                update(addPhotoUrls: list)
            } else {
                complete(false)
            }
        }
    }
    
    static func sync(complete:@escaping(_ isSucess:Bool)->Void) {
        var interval:Double = 0
        if let last = try! Realm().objects(ReviewModel.self).sorted(byKeyPath: "modifiedTimeIntervalSince1970").last {
            interval = last.modifiedTimeIntervalSince1970
        }
        let collection = Firestore.firestore().collection(FSCollectionName.REVIEW).whereField("modifiedTimeIntervalSince1970", isGreaterThanOrEqualTo: interval)
        collection.getDocuments { (snapShot, error) in
            if error == nil {
                if let data = snapShot {
                    let realm = try! Realm()
                    realm.beginWrite()
                    for doc in data.documents {
                        realm.create(ReviewModel.self, value: doc.data(), update: .all)
                    }
                    try! realm.commitWrite()
                    complete(true)
                    return
                }
            }
            
            complete(false)
        }
    }
}
