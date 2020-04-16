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
extension Notification.Name {
    static let postTalkNotification = Notification.Name(rawValue: "postTalkNotificationObserver")
}

class PostTalkViewController: UITableViewController {
    static var viewController : PostTalkViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            return storyboard.instantiateViewController(identifier: "postArticle") as! PostTalkViewController
        } else {
            return storyboard.instantiateViewController(withIdentifier: "postArticle") as! PostTalkViewController
        }
    }
    
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
        let txtPoint = textView.text.trimForPostValue.count * AdminOptions.shared.pointUseRatePosting
        return txtPoint + (selectedImage == nil ? 0 : AdminOptions.shared.pointUseUploadPicture)
    }
    
    func updateNeedPointLabel() {
        let point = needPoint.decimalForamtString
        let myPoint = UserInfo.info?.point.decimalForamtString ?? "0"
        let msg = String(format:"need point: %@, my point: %@".localized, point ,myPoint)
        textCountLabel.text = msg
        if UserInfo.info?.point ?? 0 < needPoint {
            textCountLabel.textColor = .red
        } else {
            textCountLabel.textColor = .autoColor_text_color
        }
        textCountLabel.text = msg
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AdminOptions.shared.getData {
            
        }
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

        func write() {
            sender.isEnabled = false
            if self.documentId == nil {
                TalkModel.create(text: text, image: self.selectedImage) { [weak self, weak sender] (documentId) in
                    sender?.isEnabled = true
                    if let point = self?.needPoint {
                            self?.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: .postTalkNotification,
                                                             object: nil,
                                                             userInfo:["point":point]
                            )
                    }
                }
            } else {
                self.document?.edit(text: text, image: self.selectedImage, complete: { [weak self, weak sender](sucess) in
                    if sucess {
                        if let id = self?.documentId, let point = self?.needPoint {
                            self?.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: .postTalkNotification,
                                                             object: nil,
                                                             userInfo:["talkId":id,"point":point]
                            )
                        }
                    } else {
                        sender?.isEnabled = true
                    }
                })
            }
        }
        
                
        UserInfo.info?.syncData(complete: { (_) in
            if UserInfo.info?.point ?? 0 < self.needPoint {
                let msg = String(format:"Not enough points.\nCurrent Point: %@".localized, UserInfo.info?.point.decimalForamtString ?? "0")
                let vc = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "Receive points".localized, style: .default, handler: { (_) in
                    self.googleAd.showAd(targetViewController: self) { (isSucess) in
                        if isSucess {
                            GameManager.shared.addPoint(point: AdminOptions.shared.adRewardPoint) { (isSucess) in
                                if isSucess {
                                    let msg = String(format:"%@ point get!".localized, AdminOptions.shared.adRewardPoint.decimalForamtString)
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
                vc.popoverPresentationController?.barButtonItem = sender
                self.present(vc, animated: true, completion: nil)
                sender.isEnabled = true
                return
            }
            GameManager.shared.usePoint(point: self.needPoint) { (isSucess) in
                if isSucess {
                    write()
                }
            }
        })
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
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
            ac.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: cell.contentView)
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
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
extension PostTalkViewController : UINavigationControllerDelegate {
    
}

extension PostTalkViewController : CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        debugPrint(#function)
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        debugPrint(#function)
        cropViewController.dismiss(animated: true, completion: nil)
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
