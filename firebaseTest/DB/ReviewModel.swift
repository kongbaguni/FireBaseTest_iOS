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
    static let likeUpdateNotification = Notification.Name("likeUpdateNotification_observer")
}

class ReviewModel: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var creatorId:String = ""
    @objc dynamic var reg_lat:Double = 0
    @objc dynamic var reg_lng:Double = 0
    
    @objc dynamic var place_id:String = ""
    @objc dynamic var place_detail:String = ""
    
    @objc dynamic var modified_lat:Double = 0
    @objc dynamic var modified_lng:Double = 0

    @objc dynamic var name:String = ""
    @objc dynamic var starPoint:Int = 0
    @objc dynamic var comment:String = ""
    @objc dynamic var price:Float = 0
    @objc dynamic var photoUrls:String = ""
    @objc dynamic var likeCount:Int = 0
    @objc dynamic var regTimeIntervalSince1970:Double = 0
    @objc dynamic var modifiedTimeIntervalSince1970:Double = 0
    
    @objc dynamic var localeIdentifier:String = ""
    @objc dynamic var isDeletedByAdmin:Bool = false
    
    let editList = List<ReviewEditModel>()
    let likeList = List<LikeModel>()
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["creatorId"]
    }
    
    var regDt:Date {
        return Date(timeIntervalSince1970: regTimeIntervalSince1970)
    }
    
    var modifiedDt:Date? {
        if modifiedTimeIntervalSince1970 == 0 {
            return nil
        }
        return Date(timeIntervalSince1970: modifiedTimeIntervalSince1970)
    }
    
}

class ReviewEditModel : Object {
    @objc dynamic var id:String = ""
    @objc dynamic var modified_lat:Double = 0
    @objc dynamic var modified_lng:Double = 0
    @objc dynamic var place_id:String = ""
    @objc dynamic var place_detail:String = ""
    @objc dynamic var name:String = ""
    @objc dynamic var starPoint:Int = 0
    @objc dynamic var comment:String = ""
    @objc dynamic var price:Float = 0
    @objc dynamic var photoUrls:String = ""
    @objc dynamic var modifiedTimeIntervalSince1970:Double = 0
    @objc dynamic var localeIdentifier:String = ""
    override static func primaryKey() -> String? {
        return "id"
    }
        
}

extension ReviewModel {
    var locale:Locale {
        return Locale(identifier: localeIdentifier)
    }
    
    var isLike:Bool {
        return likeList.filter("creatorId = %@",UserInfo.info?.id ?? "").count != 0
    }
    
    var creator:UserInfo? {
        return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: self.creatorId)
    }
    
    var place:AddressModel? {
        return try! Realm().object(ofType: AddressModel.self, forPrimaryKey: place_id)
    }
        
    var location:CLLocationCoordinate2D? {
        if reg_lat == 0 && reg_lng == 0 {
            return nil
        }
        return CLLocationCoordinate2D(latitude: reg_lat, longitude: reg_lng)
    }
    
    var photoUrlList:[URL] {
        var result:[URL] = []
        for str in photoUrls.components(separatedBy: ",") {
            if let url = URL(string: str) {
                result.append (url)
            }
        }
        return result.sorted { (a, b) -> Bool in
            return a.absoluteString > b.absoluteString
        }
    }
    
    var priceLocaleString:String? {
        
        price.getFormatString(locale: self.locale, style: .currency)
    }
}

extension ReviewModel {
    var addressStringValue:String {
        var result = place?.formatted_address ?? ""
        if place_detail.isEmpty == false {
            result += " \(place_detail)"
        }
        return result
    }
    
    fileprivate static func uploadImages(documentId:String, photos:[URL], complete:@escaping(_ uploadUrls:[String]?)->Void) {
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
            if let url = photolist.first {
                if url.isFileURL {
                    st.uploadImage(url: url, contentType: "image/jpeg", uploadURL: "\(FSCollectionName.STORAGE_REVIEW_IMAGE)/\(creatorId)/\(documentId)/\(UUID().uuidString).jpg") { (url) in
                        if let url = url {
                            photolist.removeFirst()
                            uploadUrls.append(url.absoluteString)
                            upload()
                        } else {
                            complete(nil)
                        }
                    }
                    return
                }
            }
            photolist.removeFirst()
            upload()
        }
        
        upload()
    }
    
    static func createReview(
        name:String,
        starPoint:Int,
        comment:String,
        price:Float,
        photos:[URL],
        place_id:String,
        place_detail:String,
        complete:@escaping(_ isSucess:Bool)->Void) {
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
                "reg_lat":UserDefaults.standard.lastMyCoordinate?.latitude ?? 0,
                "reg_lng":UserDefaults.standard.lastMyCoordinate?.longitude ?? 0,
                "place_id":place_id,
                "place_detail":place_detail,
                "localeIdentifier":Locale.current.identifier
            ]
            if uploadImages.count > 0 {
                data["photoUrls"] = uploadImages.stringValue
            }
            let doc = FS.store.collection(FSCollectionName.REVIEW).document(id)
            doc.setData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let model = realm.create(ReviewModel.self, value: data, update: .all)
                    try! realm.commitWrite()
                    // 최초 작성시 수정내역 남기기 위한 리포트 
                    model.edit(
                        name: model.name,
                        starPoint: model.starPoint,
                        comment: model.comment,
                        price: model.price,
                        addphotos: model.photoUrlList,
                        deletePhotos: [],
                        place_id: model.place_id,
                        place_detail: model.place_detail, force: true) { (sucess,_) in
                            complete(true)
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
    
    func edit(
        name:String?,
        starPoint:Int?,
        comment:String?,
        price:Float?,
        addphotos:[URL],
        deletePhotos:[String],
        place_id:String,
        place_detail:String,
        force:Bool = false,
        complete:@escaping(_ isSucess:Bool, _ isNotChnage:Bool)->Void) {
        
        if name == self.name && starPoint == self.starPoint && comment == self.comment && price == self.price && addphotos.count == 0 && deletePhotos.count == 0 && place_id == self.place_id && place_detail == self.place_detail && force == false {
            complete(false,true)
            return
        }
        
        let editId = "\(creatorId)_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
        let docId = id
        func update(addPhotoUrls:[String]) {
            var data:[String:Any] = [
                "id" : editId,
                "modified_lat" : UserDefaults.standard.lastMyCoordinate?.latitude ?? 0,
                "modified_lng" : UserDefaults.standard.lastMyCoordinate?.longitude ?? 0,
                "name" : name ?? self.name,
                "starPoint" : starPoint ?? self.starPoint,
                "comment" : comment ?? self.comment,
                "price" : price ?? self.price,
                "modifiedTimeIntervalSince1970" : Date().timeIntervalSince1970,
                "place_id" : place_id,
                "place_detail" : place_detail,
                "localeIdentifier" : Locale.current.identifier
            ]
            
            var images = Set<String>(photoUrls.components(separatedBy: ","))
            if deletePhotos.count > 0 {
                images.subtract(Set<String>(deletePhotos))
            }
            for item in addPhotoUrls {
                images.insert(item)
            }
            data["photoUrls"] = images.stringValue
            
            let document = FS.store.collection(FSCollectionName.REVIEW).document(id)
            document.collection("edit").document(editId).setData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let model = realm.create(ReviewEditModel.self, value: data, update: .all)
                    print("photos : \(model.photoUrlList.count)")
                    if let doc = realm.object(ofType: ReviewModel.self, forPrimaryKey: docId) {
                        doc.editList.append(model)
                    }
                    try! realm.commitWrite()

                    if name != nil || starPoint != nil || comment != nil || price != nil || addphotos.count > 0 || deletePhotos.count > 0 {
                        data["id"] = docId
                        document.updateData(data) { (complete) in
                            let realm = try! Realm()
                            realm.beginWrite()
                            let reviewModel = realm.create(ReviewModel.self, value: data, update: .modified)
                            print("photos : \(reviewModel.photoUrlList.count)")
                            try! realm.commitWrite()
                            NotificationCenter.default.post(name: .reviewEditNotification, object: docId)
                        }
                    }
                }
                complete(error == nil,false)
            }
        }
        
        ReviewModel.uploadImages(documentId:self.id ,photos: addphotos) { (urls) in
            if let list = urls {
                update(addPhotoUrls: list)
            } else {
                complete(false,false)
            }
        }
    }
    
    static func sync(complete:@escaping(_ isSucess:Bool)->Void) {
        var interval:Double = 0
        if let last = try! Realm().objects(ReviewModel.self).sorted(byKeyPath: "modifiedTimeIntervalSince1970").last {
            interval = last.modifiedTimeIntervalSince1970
        }
        let collection = FS.store.collection(FSCollectionName.REVIEW).whereField("modifiedTimeIntervalSince1970", isGreaterThanOrEqualTo: interval)
        
        collection.getDocuments { (snapShot, error) in
            if error == nil {
                if let data = snapShot {
                    let realm = try! Realm()
                    realm.beginWrite()
                    for doc in data.documents {
                        let review = realm.create(ReviewModel.self, value: doc.data(), update: .all)
                        let reviewId = review.id
                        let reviewDoc = FS.store.collection(FSCollectionName.REVIEW).document(doc.documentID)
                        reviewDoc.collection("like").getDocuments { (snapShot, error) in
                            if error == nil {
                                let realm = try! Realm()
                                let review = realm.object(ofType: ReviewModel.self, forPrimaryKey: reviewId)
                                realm.beginWrite()
                                review?.likeList.removeAll()
                                for likeDoc in snapShot?.documents ?? [] {
                                    let likedata = likeDoc.data()
                                    let like = realm.create(LikeModel.self, value: likedata, update: .all)
                                    review?.likeList.append(like)
                                }
                                try! realm.commitWrite()
                            }
                            
                        }
                        
                        reviewDoc.collection("edit").getDocuments { (snapShot, error) in
                            let realm = try! Realm()
                            let review = realm.object(ofType: ReviewModel.self, forPrimaryKey: reviewId)
                            realm.beginWrite()
                            review?.editList.removeAll()
                            if let editData = snapShot {
                                for edoc in editData.documents {
                                    let editModel = realm.create(ReviewEditModel.self, value: edoc.data(), update: .all)
                                    review?.editList.append(editModel)
                                }                                
                            }
                            try! realm.commitWrite()
                        }
                    }
                    try! realm.commitWrite()
                    complete(true)
                    return
                }
            }
            
            complete(false)
        }
    }
    
    func toggleLike(complete:@escaping(_ isLike:Bool?)->Void) {
        guard let myid = UserInfo.info?.id else {
            complete(false)
            return
        }
        let id = self.id
        let likeId = "\(id)_\(myid)"
        let likeData:[String:Any] = [
            "id":likeId,
            "creatorId":myid,
            "targetId":id,
            "regTimeIntervalSince1970":Date().timeIntervalSince1970
        ]
        
        func updateReview() {
            let data:[String:Any] = [
                "id":self.id,
                "modifiedTimeIntervalSince1970":Date().timeIntervalSince1970
            ]
            FS.store.collection(FSCollectionName.REVIEW).document(self.id).updateData(data) { (error) in
                if error == nil {
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.create(ReviewModel.self, value: data, update: .modified)
                    try! realm.commitWrite()
                }
            }
        }
        
        func getTargetUsersLikeCount(getCount:@escaping(_ count:Int?)->Void) {
            let targetUsersLike = FS.store.collection(FSCollectionName.USERS).document(self.creatorId).collection("like")
            targetUsersLike.getDocuments { (shot, error) in
                if error == nil {
                    getCount(shot?.documents.count)
                }
            }
        }
    
        let doc = FS.store.collection(FSCollectionName.REVIEW).document(id)
        let reviewer = FS.store.collection(FSCollectionName.USERS).document(creatorId)
        let reviewersLike = reviewer.collection("like")
        
        func makeLikes(makeComplete:@escaping(_ sucess:Bool)->Void) {
            doc.collection("like").getDocuments { (snapShot, error) in
                if let data = snapShot {
                    let realm = try! Realm()
                    if let model = realm.object(ofType: ReviewModel.self, forPrimaryKey: id) {
                        realm.beginWrite()
                        model.likeList.removeAll()
                        for like in data.documents {
                            let like = realm.create(LikeModel.self, value: like.data(), update: .all)
                            model.likeList.append(like)
                        }
                        try! realm.commitWrite()
                    }
                }
                makeComplete(error == nil)
                getTargetUsersLikeCount { (count) in
                    if let c = count {
                        self.creator?.update(data:["count_of_recive_like":c] , complete: { (sucess) in
                            
                        })
                    }
                }
            }
        }
        
        doc.collection("like").whereField("creatorId", isEqualTo: myid).getDocuments { (snapShot, error) in
            if let data = snapShot {
                if data.documents.count == 0 {
                    doc.collection("like").document(likeId).setData(likeData) { (error) in
                        if error == nil {
                            makeLikes { (sucess) in
                                UserInfo.info?.updateForRanking(type: .count_of_like, addValue: 1 , complete: { (sucess) in
                                    
                                })
                                updateReview()
                                NotificationCenter.default.post(name: .likeUpdateNotification, object: nil, userInfo: nil)
                                complete(true)
                            }
                        }
                    }
                    reviewersLike.document(likeId).setData(likeData)
                    
                } else if let data = data.documents.first {
                    doc.collection("like").document(data.documentID).delete { (error) in
                        if error == nil {
                            makeLikes { (sucess) in
                                UserInfo.info?.updateForRanking(type: .count_of_like, addValue: -1 , complete: { (sucess) in
                                    
                                })
                                updateReview()
                                NotificationCenter.default.post(name: .likeUpdateNotification, object: nil, userInfo: nil)
                                complete(false)
                            }
                        }
                    }
                    reviewersLike.document(likeId).delete { (error) in
                        
                    }
                }
                return
            }
            complete(nil)
        }
        
    }
    
    /** 관리자가 삭제*/
    func deleteByAdmin(complete:@escaping(_ isSucess:Bool)->Void) {
        let data:[String:Any] = [
            "id":id,
            "isDeletedByAdmin":true,
            "modifiedTimeIntervalSince1970":Date().timeIntervalSince1970
        ]
        let doc = FS.store.collection(FSCollectionName.REVIEW)
        doc.document(id).updateData(data) { (error) in
            if error == nil {
                let realm = try! Realm()
                realm.beginWrite()
                realm.create(ReviewModel.self, value: data, update: .modified)
                try! realm.commitWrite()
            }
            complete(error == nil)
        }
    }
}


extension ReviewEditModel {
    var addressStringValue:String {
        var result = place?.formatted_address ?? ""
        if place_detail.isEmpty == false {
            result += " \(place_detail)"
        }
        return result
    }
    
    var photoUrlList:[URL] {
        var result:[URL] = []
        for str in photoUrls.components(separatedBy: ",") {
            if let url = URL(string: str) {
                result.append (url)
            }
        }
        
        return result.sorted { (a, b) -> Bool in
            return a.absoluteString > b.absoluteString
        }
    }
    
    var modifiedDt:Date? {
        if modifiedTimeIntervalSince1970 == 0 {
            return nil
        }
        return Date(timeIntervalSince1970: modifiedTimeIntervalSince1970)
    }
    
    var location:CLLocationCoordinate2D? {
        if modified_lat == 0 && modified_lng == 0 {
            return nil
        }
        return CLLocationCoordinate2D(latitude: modified_lat, longitude: modified_lng)
    }

    var place:AddressModel? {
        return try! Realm().object(ofType: AddressModel.self, forPrimaryKey: place_id)
    }
    
    var locale:Locale {
        return Locale(identifier: localeIdentifier)
    }
    
    var priceLocaleString:String? {
        price.getFormatString(locale: self.locale, style: .currency)
    }
    
}
