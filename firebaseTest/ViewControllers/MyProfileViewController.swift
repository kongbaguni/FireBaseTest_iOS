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
import AlamofireImage
import RealmSwift

class MyProfileViewController: UITableViewController {
    
    private var profileImageBase64String:String? = nil
    
    enum ProfileImageDeleteMode {
        case delete
        case googlePhoto
    }
    
    var profileImageDeleteMode:ProfileImageDeleteMode? = nil {
        didSet {
            if profileImageDeleteMode != nil {
                profileImage = nil
            }
        }
    }
    
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
            let image = newValue?.af_imageAspectScaled(toFit: CGSize(width: 100, height: 100))
            profileImageBase64String = image?.pngData()?.base64EncodedString()
            profileImageView.setImage(image: image, placeHolder: #imageLiteral(resourceName: "profile"))
            if image != nil {
                profileImageDeleteMode = nil
            }
        }
    }
    
    let dbCollection = Firestore.firestore().collection("users")
    
    let storageRef = Storage.storage().reference()
    let indicatorView = NVActivityIndicatorView(frame: UIScreen.main.bounds, type: .ballRotateChase, color: .indicator_color, padding: UIScreen.main.bounds.width)
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var introduceLabel: UILabel!
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var introduceTextView : UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    deinit {
        debugPrint("deinit \(#file)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "myProfile".localized
        view.addSubview(indicatorView)
        setTitle()
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "save".localized, style: .done, target: self, action: #selector(self.onTouchupSave(_:)))
        
        loadData()
        if let userInfo = UserInfo.info {
            userInfo.syncData { isNew in
                self.loadData()
            }
        }
    }
    
    private func loadData() {
        if let userInfo = UserInfo.info {
            self.nameTextField.text = userInfo.name
            self.introduceTextView.text = userInfo.introduce
            self.profileImageView.kf.setImage(with: userInfo.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
        }
    }
    
    private func setTitle() {
        introduceLabel.text = "introduce".localized
        photoLabel.text = "photo".localized
        nameLabel.text = "name".localized
    }
    
    @objc func onTouchupSave(_ sender:UIBarButtonItem) {
        view.endEditing(true)
        /** 이미지 업로드*/
        func uploadImage(complete:@escaping(_ isSucess:Bool)->Void) {
            if let str = profileImageBase64String {
                if let data = Data(base64Encoded: str) {
                    FirebaseStorageHelper().uploadImage(
                        withData: data,
                        contentType: "image/png",
                        uploadURL: "profileImages/\(UserInfo.info!.id).png") { (downloadUrl) in
                            if (downloadUrl != nil) {
                                print(downloadUrl?.absoluteString ?? "없다")
                                do {
                                    let realm = try Realm()
                                    realm.beginWrite()
                                    UserInfo.info?.profileImageURLfirebase = downloadUrl?.absoluteString ?? ""
                                    try realm.commitWrite()
                                } catch {
                                    print(error.localizedDescription)
                                    complete(false)
                                    return
                                }
                            }
                            complete(true)
                    }
                    return
                }
            }
            complete(true)
        }
        
        /** 프로필 업데이트*/
        func updateProfile(complete:@escaping()->Void) {
            guard let userinfo = UserInfo.info else {
                return
            }
            let realm = try! Realm()
            realm.beginWrite()
            userinfo.name = nameTextField.text ?? ""
            userinfo.introduce = introduceTextView.text ?? ""
            userinfo.isDeleteProfileImage = profileImageDeleteMode == .delete
            
            if profileImageDeleteMode != nil {
                userinfo.profileImageURLfirebase = ""
            }
            try! realm.commitWrite()
            
            userinfo.updateData() {
                complete()
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
        //        "camera" = "카메라";
        //        "photoLibrary" = "사진 앨범";
        //        "cancel" = "취소";
        //        "confirm" = "확인";
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "camera".localized, style: .default, handler: { (_) in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "photoLibrary".localized, style: .default, handler: { (_) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "use google profile image".localized, style: .default, handler: { (_) in
            self.profileImageDeleteMode = .googlePhoto
            self.profileImageView.setImageUrl(url: UserInfo.info?.profileImageURLgoogle, placeHolder: #imageLiteral(resourceName: "profile"))
        }))
        
        ac.addAction(UIAlertAction(title: "delete".localized, style: .default, handler: { (_) in
            self.profileImageDeleteMode = .delete
        }))
        ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
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
        if let image = info[.originalImage] as? UIImage {
            let cropvc = CropViewController(croppingStyle: .default, image: image)            
            cropvc.delegate = self
            cropvc.aspectRatioLockEnabled = true
            cropvc.customAspectRatio = CGSize(width:300,height:300)
            present(cropvc, animated: true, completion: nil)
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
        cropViewController.dismiss(animated: true, completion: nil)
        profileImage = image
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        debugPrint(#function)
        cropViewController.dismiss(animated: true, completion: nil)
        profileImage = image
    }
}
