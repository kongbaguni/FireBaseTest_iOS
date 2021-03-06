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
import RxCocoa
import RxSwift
import StoreKit
import FirebaseAuth
extension Notification.Name {
    static let profileUpdateNotification = Notification.Name("profileUPdateNotification_observer")
}

class MyProfileViewController: UITableViewController {

    var authDataResult:AuthDataResult? = nil
    
    class var viewController : MyProfileViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "myProfile") as! MyProfileViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myProfile") as! MyProfileViewController
        }
    }
    
    var profileImageUrl:URL? = nil {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.profileImageView?.kf.setImage(with: self?.profileImageUrl, placeholder: UIImage.placeHolder_profile)
            }
        }
    }
    
    var hideLeaveCell = false
    
    enum ProfileImageDeleteMode {
        case delete
        case googlePhoto
    }
    
    var profileImageDeleteMode:ProfileImageDeleteMode? = nil {
        didSet {
            if profileImageDeleteMode != nil {
                profileImageUrl = nil
            }
        }
    }
    
    
    let dbCollection = FS.store.collection(FSCollectionName.USERS)
    
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
    let disposebag = DisposeBag()
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
        nameTextField.rx.text.orEmpty.bind { [weak self](string) in
            let trimTxt = string.trimmingCharacters(in: CharacterSet(charactersIn: " "))
            if trimTxt.count > 20 {
                let newValue = trimTxt[0..<20]
                self?.nameTextField.text = newValue
            }
        }.disposed(by: disposebag)
        introduceTextView.rx.text.orEmpty.bind { [weak self] (string) in
            let trimTxt = string.trimmingCharacters(in: CharacterSet(charactersIn: " "))
            if trimTxt.count > 300 {
                let newValue = trimTxt[0..<300]
                self?.introduceTextView.text = newValue
            }
        }.disposed(by: disposebag)
    }
    
    private func loadData() {        
        if let data = authDataResult {
            self.nameTextField.text = data.name
        }
        if let userInfo = UserInfo.info {
            if userInfo.name.isEmpty == false {
                self.nameTextField.text = userInfo.name
            }
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
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in [introduceTextView, searchDistanceTextField, nameTextField, mapTypeTextFiled] {
            view?.setBorder(borderColor: .autoColor_weak_text_color, borderWidth: 0.5, radius: 5)
        }
    }
    
    @objc func onTouchupSave(_ sender:UIBarButtonItem) {
        view.endEditing(true)
        /** 이미지 업로드*/
        func uploadImage(complete:@escaping(_ imageUrl:String?)->Void) {
            if let url = profileImageUrl {
                let uploadURL = "\(FSCollectionName.STORAGE_PROFILE_IMAGE)/\(UserInfo.info!.id).png"
                ImageModel.upload(url: url, type: .profile, uploadURL:uploadURL) { (url) in
                    complete(url)
                }
                return
            }
            complete(nil)
        }
        
        /** 프로필 업데이트*/
        func updateProfile(profileImageUrl:String?,complete:@escaping(_ isSucess:Bool)->Void) {
            guard let userinfo = UserInfo.info else {
                return
            }
            if userinfo.distanceForSearch != selectSearchDistance {
                StoreModel.deleteAll()
            }
            var data:[String:Any] = [
                "id" : userinfo.id,
                "name" : nameTextField.text?.trimmingCharacters(in: CharacterSet(charactersIn: " ")) ?? "",
                "introduce" : introduceTextView.text.trimmingCharacters(in: CharacterSet(charactersIn: " ")),
                "isDeleteProfileImage" : (profileImageDeleteMode == .delete || userinfo.profileImageURLgoogle.isEmpty == true && profileImageUrl == nil),
                "distanceForSearch" : selectSearchDistance,
                "isAnonymousInventoryReport" : anonymousInventoryReportTitleSwitch.isOn,
                "updateTimeIntervalSince1970" : Date().timeIntervalSince1970,
                "mapType" : selectMapViewMapType.rawValue
            ]
            if let url = profileImageUrl {
                if let image = ImageModel.imageWithThumbURL(url: url) {
                    data["profileImageURLfirebase"] = image.largeURLstr
                    data["profileThumbURLfirebase"] = image.thumbURLstr
                }
            }
            switch profileImageDeleteMode {
            case .delete, .googlePhoto:
                data["profileImageURLfirebase"] = ""
                data["profileThumbURLfirebase"] = ""
            default:
                break
            }
            
            
            userinfo.update(data: data) { (sucess) in
                complete(sucess)
                NotificationCenter.default.post(name: .profileUpdateNotification, object: nil)
            }
        }
        
        loading.show(viewController: self)
        uploadImage { downloadUrl in
            updateProfile(profileImageUrl: downloadUrl) { (isSucess) in
                self.loading.hide()
                if isSucess {
                    if self.navigationController?.viewControllers.first == self {
                        UIApplication.shared.rootViewController = MainTabBarController.viewController
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.alert(title: "alert".localized, message: "join fail msg".localized)
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
        if UserInfo.info?.profileImageURLgoogle.isEmpty == false {
            ac.addAction(UIAlertAction(title: "use google profile image".localized, style: .default, handler: { (_) in
                guard let googleProfileUrl = UserInfo.info?.profileImageURLgoogle ?? UserDefaults.standard.string(forKey: "profileTemp") else {
                    return
                }
                self.profileImageDeleteMode = .googlePhoto
                self.profileImageView.setImage(url: URL(string: googleProfileUrl)!, placeholder: .placeHolder_profile)
//                self.profileImageView.setImageUrl(url: googleProfileUrl, placeHolder: .placeHolder_profile)
                
                complete()
            }))
        }
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if authDataResult != nil {
                return 0
            }
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
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
                FS.store.collection(FSCollectionName.USERS).document(UserInfo.info?.id ?? "").delete { [weak self] (error) in
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        if error == nil {
                            UserInfo.info?.logout()
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
        let url = image.af.imageAspectScaled(toFill: Consts.PROFILE_IMAGE_SIZE).save(name: "profileImageTemp.png")
        profileImageUrl = url
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        debugPrint(#function)
        cropViewController.dismiss(animated: true, completion: nil)
        let url = image.af.imageAspectScaled(toFill: Consts.PROFILE_IMAGE_SIZE).save(name: "profileImageTemp.png")
        profileImageUrl = url
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
