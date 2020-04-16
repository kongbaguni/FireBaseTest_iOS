//
//  MyReviewWriteController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/31.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import CropViewController
import RealmSwift

fileprivate extension Notification.Name {
    static let image_delete_noti = Notification.Name(rawValue: "image_delete_noto_observer")
}


fileprivate extension Array {
    var imgDataArray:[Data] {
        var result:[Data] = []
        for item in self {
            if let img = item as? UIImage {
                if let data = img.af.imageAspectScaled(toFit: CGSize(width: 1000, height: 1000)).jpegData(compressionQuality: 0.7) {
                    result.append(data)
                }
            }
        }
        return result
    }
}

class MyReviewWriteController: UITableViewController {
    static var viewController : MyReviewWriteController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(identifier: "write") as! MyReviewWriteController
        } else {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(withIdentifier: "write") as! MyReviewWriteController
        }
    }
    
    @IBOutlet weak var needPointLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var starPoiontLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var pointTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var imageAddBtn: UIButton!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    let disposBag = DisposeBag()
    
    let loading = Loading()
    let starPointPicker = UIPickerView()
    
    class SelectImages {
        let image:UIImage?
        let path:String?
        init(image:UIImage?, path:String?) {
            self.image = image
            self.path = path
        }
    }
    
    var selectedImages:[SelectImages] = []
    var newImages:[UIImage] {
        var result:[UIImage] = []
        for item in selectedImages {
            if let image = item.image {
                result.append(image)
            }
        }
        return result
    }
    
    var deletedImages:[String] = []
    var reviewId:String? = nil
    
    var review:ReviewModel? {
        if let id = reviewId {
            return try! Realm().object(ofType: ReviewModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    var needPoint:Int {
        let a = commentTextView.text.count * AdminOptions.shared.pointUseRatePosting
        let b = selectedImages.filter { (image) -> Bool in
            return image.image != nil
        }.count * AdminOptions.shared.pointUseUploadPicture
        return a + b
    }
    
    func updateNeedPointLabel() {
          let point = needPoint.decimalForamtString
          let myPoint = UserInfo.info?.point.decimalForamtString ?? "0"
          let msg = String(format:"need point: %@, my point: %@".localized, point ,myPoint)
        
          needPointLabel.text = msg
          if UserInfo.info?.point ?? 0 < needPoint {
              needPointLabel.textColor = .red
          } else {
              needPointLabel.textColor = .autoColor_text_color
          }
          needPointLabel.text = msg
      }
    
    override func viewDidLoad() {
        title = "write review".localized
        super.viewDidLoad()
        for view in [nameTextField, priceTextField, pointTextField, commentTextView] {
            view?.setBorder(borderColor: .autoColor_weak_text_color, borderWidth: 0.5, radius: 10, masksToBounds: true)
        }
        setTitle()
        pointTextField.inputView = starPointPicker
        starPointPicker.dataSource = self
        starPointPicker.delegate = self
        
        imageAddBtn.rx.tap.bind { (_) in
            let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            vc.popoverPresentationController?.barButtonItem = UIBarButtonItem(customView: self.imageAddBtn)
            vc.addAction(UIAlertAction(title: "camera".localized, style: .default, handler: { (action) in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }))
            vc.addAction(UIAlertAction(title: "photoLibrary".localized, style: .default, handler: { (_) in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }))
            vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            self.present(vc, animated: true, completion: nil)
        }.disposed(by: disposBag)
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        priceTextField.rx.text.orEmpty.bind { (query) in
            if query.count > 1 {
                self.priceTextField.text = query.currencyIntValue.currencyFormatString
            } else {
                self.priceTextField.text = 0.currencyFormatString
            }
        }.disposed(by: disposBag)
        loadData()
        
        commentTextView.rx.text.orEmpty.bind { (query) in
            self.updateNeedPointLabel()
        }.disposed(by: disposBag)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(self.onTouchSaveBtn(_:)))
        
        NotificationCenter.default.addObserver(forName: .image_delete_noti, object: nil, queue: nil) { [weak self] (notification) in
            if let cell = notification.object as? MyReviewWriteImageCollectionViewCell,
                let s = self   {
                
                let path = cell.imageUrl
                let image = path != nil ? nil : cell.imageView.image
                let item = SelectImages(image: image, path: path)
                if let index = s.selectedImages.lastIndex(where: { (image) -> Bool in
                    if image.image == item.image {
                        return true
                    }
                    if image.path == item.path {
                        return true
                    }
                    else {
                        return false
                    }
                }) {
                    s.selectedImages.remove(at: index)
                    print(s.selectedImages.count)
                    s.imageCollectionView.reloadData()
                }
                if let path = item.path {
                    s.deletedImages.append(path)
                }
                s.updateNeedPointLabel()
            }
        }
    }
    
    @objc func onTouchSaveBtn(_ sender:UIBarButtonItem) {
        sender.isEnabled = false
        GameManager.shared.usePoint(point: self.needPoint) { [weak self, weak sender] (sucess) in
            guard let s = self else {
                sender?.isEnabled = true
                return
            }
            if sucess {
                let point = s.pointTextField.text?.count ?? 1
                let price = s.priceTextField.text!.currencyIntValue
                
                if s.reviewId == nil {
                    s.loading.show(viewController: s)
                    ReviewModel.createReview(
                        name: s.nameTextField.text!,
                        starPoint: point,
                        comment: s.commentTextView.text!,
                        price: price,
                        photos: s.newImages.imgDataArray) { [weak s] (sucess) in
                            s?.loading.hide()
                            if sucess {
                                s?.navigationController?.popViewController(animated: true)
                            } else {
                                sender?.isEnabled = true
                            }
                    }
                } else {
                    s.loading.show(viewController: s)
                    s.review?.edit(
                        name: s.nameTextField.text,
                        starPoint: point,
                        comment: s.commentTextView.text!,
                        price: price,
                        addphotos: s.newImages.imgDataArray,
                        deletePhotos: s.deletedImages,
                        complete: { [weak s](sucess) in
                            s?.loading.hide()
                            if sucess {
                                s?.navigationController?.popViewController(animated: true)
                            } else {
                                sender?.isEnabled = true
                            }
                    })
                }
            }
            else {
                if let s = sender {
                    GameManager.shared.showAd(popoverView: s) {[weak self] in
                        self?.onTouchSaveBtn(s)
                    }
                }
            }
        }

    }
    
    func setTitle() {
        nameLabel.text = "food name".localized
        priceLabel.text = "price".localized
        starPoiontLabel.text = "starPoint".localized
        commentLabel.text = "comment".localized
    }
    
    func loadData() {
        guard let data = review else {
            nameTextField.text = ""
            priceTextField.text = ""
            pointTextField.text = ""
            commentTextView.text = ""
            return
        }
        nameTextField.text = data.name
        priceTextField.text = data.price.currencyFormatString
        pointTextField.text = data.starPoint.decimalForamtString
        if data.starPoint > Consts.stars.count {
            pointTextField.text =  Consts.stars.last
        } else if data.starPoint == 0 {
            pointTextField.text =  Consts.stars.first
        } else {
            pointTextField.text =  Consts.stars[data.starPoint - 1]
        }
        starPointPicker.selectRow((pointTextField.text?.count ?? 1)-1, inComponent: 0, animated: false)
        commentTextView.text = data.comment
        for str in data.photoUrls.components(separatedBy: ",") {
            if str.trimmingCharacters(in: CharacterSet(charactersIn: " ")).isEmpty == false {
                self.selectedImages.append(SelectImages(image: nil, path: str))
            }
        }
        
        imageCollectionView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            return "image".localized
        default:
            return nil
        }
    }
    
}

extension MyReviewWriteController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! MyReviewWriteImageCollectionViewCell
        let data = selectedImages[indexPath.row]
        if let image = data.image {
            cell.imageUrl = nil
            cell.imageView.image = image
        }
        if let url = data.path {
            cell.imageUrl = url
            cell.imageView.kf.setImage(with: URL(string: url),placeholder:#imageLiteral(resourceName: "placeholder"))
        }
        return cell
    }
}

extension MyReviewWriteController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  Consts.stars.count
    }
}
extension MyReviewWriteController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return  Consts.stars[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pointTextField.text =  Consts.stars[row]
    }
}


extension MyReviewWriteController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let data = selectedImages[indexPath.row]
//        if let str = data.path {
//            deletedImages.append(str)
//        }
//        selectedImages.remove(at: indexPath.row)
//        collectionView.deleteItems(at: [indexPath])
    }
}
extension MyReviewWriteController : UINavigationControllerDelegate {
    
}

extension MyReviewWriteController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            let cropvc = CropViewController(croppingStyle: .default, image: image)
            cropvc.delegate = self
            cropvc.aspectRatioLockEnabled = true
            cropvc.customAspectRatio = CGSize(width:300,height:300)
            present(cropvc, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        
    }
}

extension MyReviewWriteController : CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropImageToRect rect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        debugPrint(#function)
        cropViewController.dismiss(animated: true, completion: nil)
        selectedImages.append(SelectImages(image: image, path: nil))
        imageCollectionView.reloadData()
        updateNeedPointLabel()
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        debugPrint(#function)
        selectedImages.append(SelectImages(image: image, path: nil))
        imageCollectionView.reloadData()
        updateNeedPointLabel()
    }
    
}

class MyReviewWriteImageCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    let disposeBag = DisposeBag()
    var imageUrl:String? = nil
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        deleteButton.rx.tap.bind { (_) in
            NotificationCenter.default.post(name: .image_delete_noti, object: self, userInfo: nil)
            
        }.disposed(by: disposeBag)
        deleteButton.tintColor = .autoColor_text_color
        deleteButton.setImage(.closeBtnImage_normal, for: .normal)
        deleteButton.setImage(.closeBtnImage_highlighted, for: .highlighted)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

