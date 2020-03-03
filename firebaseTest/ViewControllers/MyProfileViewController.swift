//
//  MyProfileViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/02.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseFirestore
import NVActivityIndicatorView
import CropViewController
import FirebaseStorage

class MyProfileViewController: UITableViewController {
    
    private var profileImageBase64String:String? = nil
    var profileImage:UIImage? {
        get {
            if let str = profileImageBase64String {
                if let data = Data(base64Encoded: str) {
                    return UIImage(data: data)
                }
            }
            return nil
        }
        set {
            let image = newValue?.af_imageAspectScaled(toFit: CGSize(width: 30, height: 30))
            profileImageBase64String = image?.pngData()?.base64EncodedString()
            profileImageView.setImage(image: image, placeHolder: #imageLiteral(resourceName: "profile"))
        }
    }
    
    let dbCollection = Firestore.firestore().collection("users")

    let storageRef = Storage.storage().reference()
    let indicatorView = NVActivityIndicatorView(frame: UIScreen.main.bounds, type: .ballRotateChase, color: .yellow, padding: UIScreen.main.bounds.width)
    
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var introduceTextView : UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    deinit {
        debugPrint("deinit \(#file)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(indicatorView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.onTouchupSave(_:)))
        
        let document = dbCollection.document(UserDefaults.standard.userInfo!.id)
        profileImageView.setImageUrl(url: UserDefaults.standard.userInfo?.profileImageURL, placeHolder: #imageLiteral(resourceName: "profile"))
        indicatorView.startAnimating()
        document.getDocument { [weak self](snapshot, error) in
            self?.indicatorView.stopAnimating()
            let userInfo = UserDefaults.standard.userInfo
            if let doc = snapshot {
                doc.data().map { info in
                    if let name = info["name"] as? String {
                        self?.nameTextField.text = name
                        userInfo?.name = name
                    }
                    if let intro = info["intro"] as? String {
                        self?.introduceTextView.text = intro
                        userInfo?.introduce = intro
                    }
                    if let url = info["profileImageUrl"] as? String {
                        self?.profileImageView.setImageUrl(url: url, placeHolder: #imageLiteral(resourceName: "profile"))
                    }
                }
            }
        }
        
    }
    
    @objc func onTouchupSave(_ sender:UIBarButtonItem) {
        guard let userInfo = UserDefaults.standard.userInfo else {
            return
        }
        func uploadImage(complete:@escaping(_ isSucess:Bool)->Void) {
            if let str = profileImageBase64String {
                if let data = Data(base64Encoded: str) {
                    let ref:StorageReference = storageRef.child("profileImages/\(userInfo.id).png")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/png"
                    let task = ref.putData(data, metadata: metadata)
                    task.observe(.success) { (snapshot) in
                        let path = snapshot.reference.fullPath
                        print(path)
                        ref.downloadURL { (downloadUrl, err) in
                            if (downloadUrl != nil) {
                                print(downloadUrl?.absoluteString ?? "없다")
                                userInfo.profileImageURL = downloadUrl?.absoluteString
                            }
                            complete(true)
                        }

                    }
                    task.observe(.failure) { (_) in
                        complete(false)
                    }
                    return
                }
            }
            complete(true)
        }
        
        func updateProfile(complete:@escaping()->Void) {
            print(userInfo.id)
            let document = dbCollection.document(userInfo.id)
            var data = [
                "name":nameTextField.text ?? "",
                "intro":introduceTextView.text ?? "",
            ]
            if let url = UserDefaults.standard.userInfo?.profileImageURL {
                data["profileImageUrl"] = url
            }
            document.updateData(data) { [weak self](error) in
                if let e = error {
                    print(e.localizedDescription)
                    document.setData(data, merge: true) { (error) in
                        if let e = error {
                            print(e.localizedDescription)
                        }
                        else {
                            complete()
                        }
                    }
                }
                else {
                    complete()
                }
            }
        }
        
        indicatorView.startAnimating()
        uploadImage { isSucess in
            if (isSucess) {
                updateProfile {
                    self.indicatorView.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    @IBAction func onTouchupProfileImageBtn(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension MyProfileViewController : UINavigationControllerDelegate {
    
}

extension MyProfileViewController : UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        picker.dismiss(animated: true, completion: nil)
        if let url = info[.imageURL] as? URL {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    let cropvc = CropViewController(croppingStyle: .circular, image: image)
                    cropvc.delegate = self
                    present(cropvc, animated: true, completion: nil)
                }
            }
        }
        
        
    }
}

extension MyProfileViewController : CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        debugPrint(#function)
    }
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        debugPrint(#function)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        debugPrint(#function)
        profileImage = image
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        debugPrint(#function)
        cropViewController.dismiss(animated: true, completion: nil)
        profileImage = image
    }
}
