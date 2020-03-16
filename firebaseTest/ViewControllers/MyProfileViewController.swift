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
    class var viewController : MyProfileViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "myProfile") as! MyProfileViewController
    }
    
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
            let image = newValue?.af.imageAspectScaled(toFit: CGSize(width: 100, height: 100))
            profileImageBase64String = image?.pngData()?.base64EncodedString()
            profileImageView.setImage(image: image, placeHolder: #imageLiteral(resourceName: "profile"))
            if image != nil {
                profileImageDeleteMode = nil
            }
        }
    }
    
    let dbCollection = Firestore.firestore().collection("users")
    
    let storageRef = Storage.storage().reference()
    let indicatorView = NVActivityIndicatorView(frame: UIScreen.main.bounds, type: .ballRotateChase, color: .autoColor_indicator_color, padding: UIScreen.main.bounds.width)
    
    @IBOutlet weak var introduceCell: UITableViewCell!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var introduceLabel: UILabel!
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var introduceTextView : UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var searchDistanceLabel: UILabel!
    @IBOutlet weak var searchDistanceTextField: UITextField!
    
    @IBOutlet weak var anonymousInventoryReportTitleLabel: UILabel!
    @IBOutlet weak var anonymousInventoryReportTitleSwitch: UISwitch!
    
    var selectSearchDistance:Int = 0 {
        didSet {
            searchDistanceTextField.text = "\(selectSearchDistance)m"
        }
    }
    
    
    
    deinit {
        debugPrint("deinit \(#file)")
    }
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "myProfile".localized
        view.addSubview(indicatorView)
        
        pickerView.delegate = self
        pickerView.dataSource = self
        searchDistanceTextField.inputView = pickerView

        setTitle()
        introduceTextView.delegate = self
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "save".localized, style: .done, target: self, action: #selector(self.onTouchupSave(_:)))
        
        loadData()
        if let userInfo = UserInfo.info {
            userInfo.syncData { isNew in
                self.loadData()
            }
        }
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension

    }
    
    private func loadData() {
        if let userInfo = UserInfo.info {
            self.nameTextField.text = userInfo.name
            self.introduceTextView.text = userInfo.introduce
            self.profileImageView.kf.setImage(with: userInfo.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
            self.selectSearchDistance = userInfo.distanceForSearch
            if let index = Consts.SEARCH_DISTANCE_LIST.lastIndex(of: userInfo.distanceForSearch) {
                self.pickerView.selectRow(index, inComponent: 0, animated: false)
            }
            anonymousInventoryReportTitleSwitch.isOn = userInfo.isAnonymousInventoryReport
        }
    }
    
    private func setTitle() {
        introduceLabel.text = "introduce".localized
        photoLabel.text = "photo".localized
        nameLabel.text = "name".localized
        searchDistanceLabel.text = "search distance".localized
        anonymousInventoryReportTitleLabel.text = "anonymousInventoryReportTitle".localized
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
            if userinfo.distanceForSearch != selectSearchDistance {
                StoreModel.deleteAll()
            }
            
            let realm = try! Realm()
            realm.beginWrite()
            userinfo.name = nameTextField.text ?? ""
            userinfo.introduce = introduceTextView.text ?? ""
            userinfo.isDeleteProfileImage = profileImageDeleteMode == .delete
            userinfo.distanceForSearch = selectSearchDistance
            userinfo.isAnonymousInventoryReport = anonymousInventoryReportTitleSwitch.isOn
            userinfo.updateDt = Date()
            if profileImageDeleteMode != nil {
                userinfo.profileImageURLfirebase = ""
            }
            try! realm.commitWrite()
            
            userinfo.updateData() { _ in
                complete()
            }
        }
        
        indicatorView.startAnimating()
        uploadImage { isSucess in
            if (isSucess) {
                updateProfile {
                    self.indicatorView.stopAnimating()
                    if self.navigationController?.viewControllers.first == self {
                        UIApplication.shared.windows.first?.rootViewController = MainTabBarController.viewController
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
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
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

extension MyProfileViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        introduceCell.layoutSubviews()
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

extension MyProfileViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Consts.SEARCH_DISTANCE_LIST.count
    }
    
}

extension MyProfileViewController : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Consts.SEARCH_DISTANCE_LIST[row])m"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectSearchDistance = Consts.SEARCH_DISTANCE_LIST[row]
    }
}
