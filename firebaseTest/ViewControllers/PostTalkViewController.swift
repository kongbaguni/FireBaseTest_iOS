//
//  PostTalkViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift
import CropViewController

class PostTalkViewController: UITableViewController {
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var imageView:UIImageView!
    var selectedImage:UIImage? = nil {
        didSet {
            updateNeedPointLabel()
            if selectedImage == nil {
                imageView.image = #imageLiteral(resourceName: "placeholder")
            } else {
                imageView.image = selectedImage
                imageWillDelete = false
            }
        }
    }
    var imageWillDelete:Bool = false  {
        didSet {
            if imageWillDelete == true {
                selectedImage = nil
            }
        }
    }
    var documentId:String? = nil
    let disposebag = DisposeBag()
    let googleAd = GoogleAd()
    var document:TalkModel? {
        if let id = documentId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    var needPoint:Int {
        return textView.text.trimForPostValue.count + (selectedImage == nil ? 0 : 100)
    }
    
    func updateNeedPointLabel() {
        let point = needPoint.decimalForamtString
        let myPoint = UserInfo.info?.point.decimalForamtString ?? "0"
        let msg = String(format:"need point: %@, my point: %@".localized, point ,myPoint)
        textCountLabel.text = msg
        if UserInfo.info?.point ?? 0 < needPoint {
            textCountLabel.textColor = .red
        } else {
            textCountLabel.textColor = .text_color
        }
        textCountLabel.text = msg
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "write talk".localized
        if documentId != nil {
            title = "edit talk".localized
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(self.onTouchupSaveBtn(_:)))
        
        textView.text = document?.text
        imageView.kf.setImage(with: document?.imageURL, placeholder: #imageLiteral(resourceName: "placeholder") )
        if let text = document?.editList.last?.text {
            textView.text = text
        }
        textView.becomeFirstResponder()
        textView
            .rx.text
            .orEmpty
            .subscribe(onNext: { [weak self](query) in
                self?.updateNeedPointLabel()
                            
            }).disposed(by: self.disposebag)

    }
    
    @objc func onTouchupSaveBtn(_ sender:UIBarButtonItem) {
        /** 생성될 문서 아이디*/
        let documentId:String = self.documentId == nil ? "\(UUID().uuidString)\(UserInfo.info!.id)\(Date().timeIntervalSince1970)" : self.documentId!
        
        let text = textView.text.trimForPostValue
        textView.text = text
        var isEdit:Bool {
            if selectedImage != nil {
                return true
            }
            if imageWillDelete == true {
                return true
            }
            if let edit = document?.editList.last {
                return text != edit.text
            }
            return text != document?.text
        }
        if isEdit == false {
            Toast.makeToast(message: "There are no edits.".localized)
            return
        }
        if text.isEmpty {
            Toast.makeToast(message: "There is no content.".localized)
            return
        }
        if text.count > 1000 {
            Toast.makeToast(message: "It cannot exceed 1000 characters.".localized)
            return
        }
        sender.isEnabled = false

        func write(imageUrl:String?) {
            view.endEditing(true)
            Loading.show(viewController: self)
            if let id = self.documentId {
                let realm = try! Realm()
                if let document = try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id) {
                    realm.beginWrite()
                    let editText = TextEditModel()
                    var img = imageUrl
                    if self.imageWillDelete == false && img == nil {
                        img = document.imageURL?.absoluteString
                    }
                    editText.setData(text: text, imageURL: img)
                    document.insertEdit(data: editText)
                    document.modifiedTimeIntervalSince1970 = Date().timeIntervalSince1970
                    try! realm.commitWrite()
                    document.update { [weak self] (isSucess) in
                        if self != nil {
                            sender.isEnabled = true
                            Loading.hide(viewController: self!)
                            if isSucess {
                                self?.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
                return
            }
            
            
            let regTimeIntervalSince1970 = Date().timeIntervalSince1970
            let creatorId = UserInfo.info!.id
            let talk = text
            let talkModel = TalkModel()
            talkModel.loadData(id: documentId, text: talk, creatorId: creatorId, regTimeIntervalSince1970: regTimeIntervalSince1970)
            talkModel.imageUrl = imageUrl ?? ""
            talkModel.update { [weak self](sucess) in
                if self != nil {
                    sender.isEnabled = true
                    Loading.hide(viewController: self!)
                    if sucess {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        func uploadImage(complete:@escaping(_ url:String?)->Void) {
            if let data = selectedImage?.af.imageAspectScaled(toFit: CGSize(width: 800, height: 800)).pngData() {
                let uploadURL = "images/\(documentId):\(UUID().uuidString):\(Date().timeIntervalSince1970).png"
                print(uploadURL)
                FirebaseStorageHelper().uploadImage(
                    withData: data,
                    contentType: "image/png",
                    uploadURL: uploadURL) { (url) in
                        complete(url?.absoluteString)
                }
            } else {
                complete(nil)
            }
        }
        
        UserInfo.info?.syncData(syncAll: false, complete: { (_) in
            if UserInfo.info?.point ?? 0 < self.needPoint {
                let msg = String(format:"Not enough points.\nCurrent Point: %@".localized, UserInfo.info?.point.decimalForamtString ?? "0")
                let vc = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "Receive points".localized, style: .default, handler: { (_) in
                    self.googleAd.showAd(targetViewController: self) { (isSucess) in
                        if isSucess {
                            GameManager.shared.addPoint(point: Consts.POINT_BY_AD) { (isSucess) in
                                if isSucess {
                                    let msg = String(format:"%@ point get!".localized, Consts.POINT_BY_AD.decimalForamtString)
                                    Toast.makeToast(message: msg)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                        self.onTouchupSaveBtn(sender)
                                    }
                                }
                            }
                        } else {
                             self.onTouchupSaveBtn(sender)
                        }
                    }
                }))
                vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
                sender.isEnabled = true
                return
            }
            GameManager.shared.usePoint(point: self.needPoint) { (isSucess) in
                if isSucess {
                    uploadImage { (url) in
                        write(imageUrl: url)
                    }
                    
                }
            }
        })
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == imageView.superview?.superview {
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
            
            ac.addAction(UIAlertAction(title: "delete".localized, style: .default, handler: { (_) in
                self.imageWillDelete = true
            }))
            ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Contents".localized
        case 2:
            return "Attach pictures".localized
        default:
            return nil
        }
    }    
    
}

extension PostTalkViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            let cropvc = CropViewController(croppingStyle: .default, image: image)
            cropvc.delegate = self
            present(cropvc, animated: true, completion: nil)
        }
    }

}
extension PostTalkViewController : UINavigationControllerDelegate {
    
}

extension PostTalkViewController : CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        debugPrint(#function)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        debugPrint(#function)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        debugPrint(#function)
        cropViewController.dismiss(animated: true, completion: nil)
        selectedImage = image
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        debugPrint(#function)
        cropViewController.dismiss(animated: true, completion: nil)
        selectedImage = image
    }
    
}
