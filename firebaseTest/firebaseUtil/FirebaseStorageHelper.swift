//
//  FirebaseStorageHelper.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

struct FS {
    static let store = Firestore.firestore()
}

class FirebaseStorageHelper {
    let storageRef = Storage.storage().reference()
    
    func uploadImage(url:URL, contentType:String, uploadURL:String, complete:@escaping(_ downloadURL:URL?)->Void) {
        guard var data = try? Data(contentsOf: url) else {
            complete(nil)
            return
        }
        if contentType == "image/jpeg" {
            if let jpgData = UIImage(data: data)?.jpegData(compressionQuality: 0.7) {
                data = jpgData
            }
        }
        
        let ref:StorageReference = storageRef.child(uploadURL)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        let task = ref.putData(data, metadata: metadata)
        task.observe(.success) { (snapshot) in
                    let path = snapshot.reference.fullPath
                    print(path)
                    ref.downloadURL { (downloadUrl, err) in
                        if (downloadUrl != nil) {
                            print(downloadUrl?.absoluteString ?? "없다")
                        }
                        complete(downloadUrl)
                    }
                }
        task.observe(.failure) { (_) in
            complete(nil)
        }
    }

}
