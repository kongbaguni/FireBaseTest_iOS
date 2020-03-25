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
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "myProfile") as! MyProfileViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myProfile") as! MyProfileViewController
        }
    }
    
    private var profileImageBase64String:String? = nil
    
    var hideLeaveCell = false
    
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
    
    let dbCollection = Firestore.firestore().collection(FSCollectionName.USERS)
    
    let storageRef = Storage.storage().reference()
    let loading = Loading()
    
    @IBOutlet weak var introduceCell: UITableViewCell!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var introduceLabel: UILabel!
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var introduceTextView : UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var searchDistanceLabel: UILabel!
    @IBOutlet weak var searchDistanceTextField: UITextField!
    /** 탈퇴하기 라벨*/
    @IBOutlet weak var leaveLabel: UILabel!
    
    @IBOutlet weak var leaveCell: UITableViewCell!
    @IBOutlet weak var anonymousInventoryReportTitleLabel: UILabel!
    @IBOutlet weak var anonymousInventoryReportTitleSwitch: UISwitch!
    
    @IBOutlet weak var mapTypeTitleLabel: UILabel!
    @IBOutlet weak var mapTypeTextFiled: UITextField!
    
    var selectSearchDistance:Int = 0 {
        didSet {
            searchDistanceTextField.text = "\(selectSearchDistance)m"
        }
    }
    
    var selectMapViewMapType:UserInfo.MapType = .standard {
        didSet {
            print("--------------------------")
            print(selectMapViewMapType.rawValue.localized)
            DispatchQueue.main.async {[weak self] in
                self?.mapTypeTextFiled.text = self?.selectMapViewMapType.rawValue.localized
            }
        }
    }
    
    deinit {
        debugPrint("deinit \(#file)")
    }
    
    let searchDistancePickerView = UIPickerView()
    let mapTypePickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "myProfile".localized
        for pickerView in [searchDistancePickerView, mapTypePickerView] {
            pickerView.delegate = self
            pickerView.dataSource = self
        }
        searchDistanceTextField.inputView = searchDistancePickerView
        mapTypeTextFiled.inputView = mapTypePickerView
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
        leaveCell.isHidden = hideLeaveCell
    }
    
    private func loadData() {
        if let userInfo = UserInfo.info {
            self.nameTextField.text = userInfo.name
            self.introduceTextView.text = userInfo.introduce
            self.profileImageView.kf.setImage(with: userInfo.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
            self.selectSearchDistance = userInfo.distanceForSearch
            if let index = Consts.SEARCH_DISTANCE_LIST.lastIndex(of: userInfo.distanceForSearch) {
                self.searchDistancePickerView.selectRow(index, inComponent: 0, animated: false)
            }
            if let index = UserInfo.MapType.allCases.lastIndex(of: userInfo.mapTypeValue) {
                self.mapTypePickerView.selectRow(index, inComponent: 0, animated: false)
            }
            
            selectMapViewMapType = userInfo.mapTypeValue
            anonymousInventoryReportTitleSwitch.isOn = userInfo.isAnonymousInventoryReport
            mapTypeTextFiled.text = userInfo.mapType.localized
        }
    }
    
    private func setTitle() {
        introduceLabel.text = "introduce".localized
        photoLabel.text = "photo".localized
        nameLabel.text = "name".localized
        searchDistanceLabel.text = "search distance".localized
        anonymousInventoryReportTitleLabel.text = "anonymousInventoryReportTitle".localized
        leaveLabel.text = "leave".localized
        leaveCell.isHidden = self.hideLeaveCell
        
        for view in [introduceTextView, searchDistanceTextField, nameTextField, mapTypeTextFiled] {
            view?.setBorder(borderColor: .autoColor_weak_text_color, borderWidth: 0.5, radius: 5)
        }
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
                        uploadURL: "\(FSCollectionName.STORAGE_PROFILE_IMAGE)/\(UserInfo.info!.id).png") { (downloadUrl) in
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
            userinfo.mapTypeValue = selectMapViewMapType
            if profileImageDeleteMode != nil {
                userinfo.profileImageURLfirebase = ""
            }
            try! realm.commitWrite()
            
            userinfo.updateData() { _ in
                complete()
            }
        }
        
        loading.show(viewController: self)
        uploadImage { isSucess in
            if (isSucess) {
                updateProfile {
                    self.loading.hide()
                    if self.navigationController?.viewControllers.first == self {
                        UIApplication.shared.rootViewController = MainTabBarController.viewController
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func onTouchupProfileImageBtn(sender:UIView,complete:@escaping()->Void) {
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
            complete()
        }))
        ac.addAction(UIAlertAction(title: "photoLibrary".localized, style: .default, handler: { (_) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
            complete()
        }))
        ac.addAction(UIAlertAction(title: "use google profile image".localized, style: .default, handler: { (_) in
            self.profileImageDeleteMode = .googlePhoto
            self.profileImageView.setImageUrl(url: UserInfo.info?.profileImageURLgoogle, placeHolder: #imageLiteral(resourceName: "profile"))
            complete()
        }))
        
        ac.addAction(UIAlertAction(title: "delete".localized, style: .default, handler: { (_) in
            self.profileImageDeleteMode = .delete
            complete()
        }))
        ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel) { _ in
            complete()
        })
        ac.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: sender)
        present(ac, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        switch cell.reuseIdentifier {
        case "photo":
            self.onTouchupProfileImageBtn(sender: cell.contentView) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case "leave":
            let vc = UIAlertController(title: "leave alert msg title".localized,
                                       message: "leave alert msg desc".localized, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "leave".localized, style: .default, handler: { (_) in
                Firestore.firestore().collection(FSCollectionName.USERS).document(UserInfo.info?.id ?? "").delete { [weak self] (error) in
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        if error == nil {
                            UserInfo.info?.logout(isDeleteAll: true)
                        }
                    }
                }
            }))
            vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel){ [weak self] _ in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            vc.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: cell.contentView)
            present(vc, animated: true, completion: nil)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
            
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if cell.reuseIdentifier == "leave" {
            cell.isHidden = hideLeaveCell
        }
        return cell
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
        picker.dismiss(animated: true, completion: nil)
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
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
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
        switch pickerView{
        case mapTypePickerView:
            return UserInfo.MapType.allCases.count
        case searchDistancePickerView:
            return Consts.SEARCH_DISTANCE_LIST.count
        default:
            return 0
        }
    }
    
}

extension MyProfileViewController : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case mapTypePickerView:
            return UserInfo.MapType.allCases[row].rawValue.localized
        case searchDistancePickerView:
            return "\(Consts.SEARCH_DISTANCE_LIST[row])m"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView{
        case mapTypePickerView:
            mapTypeTextFiled.text = UserInfo.MapType.allCases[row].rawValue.localized
            selectMapViewMapType = UserInfo.MapType.allCases[row]
            
        case searchDistancePickerView:
            selectSearchDistance = Consts.SEARCH_DISTANCE_LIST[row]
        default:
            break
        }
    }
    
}
