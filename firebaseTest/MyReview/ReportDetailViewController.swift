//
//  ReportDetailViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import Lightbox
import RxCocoa
import RxSwift

class ReportDetailViewController: UITableViewController {
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var rejectBtn:UIButton!
    @IBOutlet weak var deleteBtn:UIButton!
    @IBOutlet weak var addBlackListBtn:UIButton!
    
    var reportId:String? = nil
    
    var report:ReportModel? {
        if let id = reportId {
            return try! Realm().object(ofType: ReportModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = report?.desc
        UserInfo.syncUserInfo {
            self.tableView.reloadData()
        }
        
        rejectBtn.rx.tap.bind { [weak self](_) in
            self?.report?.check(complete: { (isSucess) in
                self?.navigationController?.popViewController(animated: true)
            })
        }.disposed(by: disposeBag)
        
        deleteBtn.rx.tap.bind { [weak self](_) in
            let ac = UIAlertController(title: nil, message: "삭제합니다", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (_) in
                if let talk = self?.report?.target as? TalkModel {
                    talk.deleteByAdmin { (isSucess) in
                        if isSucess {
                            self?.report?.check(complete: { (isSucess) in
                                self?.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                }
                if let review = self?.report?.target as? ReviewModel {
                    review.deleteByAdmin { (isSucess) in
                        if isSucess {
                            self?.report?.check(complete: { (isSucess) in
                                self?.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                }
            }))
            ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            self?.present(ac, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        addBlackListBtn.rx.tap.bind {[weak self](_) in
            let ac = UIAlertController(title: nil, message: "글쓰기 차단합니다.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { [weak self](_) in
                var u:UserInfo? = nil
                if let user = self?.report?.target as? UserInfo {
                    u = user
                }
                if let user = (self?.report?.target as? TalkModel)?.creator {
                    u = user
                }
                if let user = (self?.report?.target as? ReviewModel)?.creator {
                    u = user
                }
                u?.blockPostingUser(isBlock: true, complete: { (isSucess) in
                    if isSucess {
                        self?.report?.check(complete: { (isSucess) in
                            self?.navigationController?.popViewController(animated: true)
                        })
                    }
                })
            }))
            ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            self?.present(ac, animated: true, completion: nil)
                        
        }.disposed(by: disposeBag)

        
    }
    
    enum DataType {
        case targetName
        case targetEmail
        case targetText
        case targetImage
        case targetRegDt
        case reporterName
        case reporterEmail
        case reportRegDt
        case reportReson
    }
    
    let dataTypes:[[DataType]] = [
        [
//            .reporterName
            .reporterEmail,
            .reportRegDt,
            .reportReson
        ],
        [
//            .targetName,
            .targetEmail,
            .targetText,
            .targetRegDt
        ],
        [
            .targetImage
        ]
    ]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataTypes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if ((report?.target as? TalkModel)?.imageURL != nil) {
                return 1
            }
            if let count = (report?.target as? ReviewModel)?.photoUrlList.count {
                return count
            }
        }
        return dataTypes[section].count
    }
    
    func getText(indexPath:IndexPath)->String {
        var text = ""
        switch dataTypes[indexPath.section][indexPath.row] {
        case .reportRegDt:
            text += "신고 시각 "
            if let regdt = report?.regDt.relativeTimeStringValue {
                text += regdt
            }
        case .reporterName:
            text += "이름 : "
            if let name = report?.reporter?.name {
                text += name
            }
        case .reporterEmail:
            text += "이메일 : "
            if let email = report?.reporter?.email {
                text += email
            }
        case .reportReson:
            text += "신고 사유 : "
            text += report?.resonType.rawValue.localized ?? ""
            if report?.reson.isEmpty != false {
                text += "\n\(report?.reson ?? "" )"
            }
        case .targetRegDt:
            if let model = report?.target as? TalkModel {
                let dt = model.regDt.relativeTimeStringValue
                text += "대화 등록 시각 : \(dt)"
                if let dt = model.modifiedDt?.relativeTimeStringValue {
                    text += "\n대화 수정 시각: \(dt)"
                }
            }
            if let model = report?.target as? ReviewModel {
                let dt = model.regDt.relativeTimeStringValue
                text += "리뷰 수정 시각 : \(dt)"
                if let dt = model.modifiedDt?.relativeTimeStringValue {
                    text += "\n리뷰 수정 시각 : \(dt)"
                }
            }
            if let dt = (report?.target as? UserInfo)?.lastTalkDt?.relativeTimeStringValue {
                text += "마지막 대화 작성 시각 : \(dt)"
            }
        case .targetName:
            text += "이름 : "
            if let name = (report?.target as? UserInfo)?.name {
                text += name
            }
            else if let name = (report?.target as? TalkModel)?.creator?.name {
                text += name
            }
            else if let name = (report?.target as? ReviewModel)?.creator?.name {
                text += name
            }
        case .targetEmail:
            text += "이메일 : "
            if let name = (report?.target as? UserInfo)?.email {
                text += name
            }
            else if let name = (report?.target as? TalkModel)?.creator?.email {
                text += name
            }
            else if let name = (report?.target as? ReviewModel)?.creator?.email {
                text += name
            }
        case .targetText:
            text += "[내용] "
            if let name = (report?.target as? UserInfo)?.name {
                text += "\n불량 유저 \(name) 에 대한 신고"
            }
            else if let talk = (report?.target as? TalkModel)?.text {
                text += talk
            }
            else if let review = (report?.target as? ReviewModel) {
                text += "\nname : \(review.name) \ncomment : \(review.comment)"
            }
            
        default:
            break
        }
        return text
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "reporter"
        case 1:
            return "target"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath)
            if let target = report?.target as? TalkModel {
                if let url = target.imageURL {
                    cell.imageView?.kf.setImage(with: url, placeholder: UIImage.placeHolder_image)
                }
            }
            if let urls = (report?.target as? ReviewModel)?.photoUrlList {
                cell.imageView?.kf.setImage(with: urls[indexPath.row], placeholder: UIImage.placeHolder_image)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath)
            cell.textLabel?.text = getText(indexPath: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 2:
            if let list = (report?.target as? ReviewModel)?.photoUrlList {
                let imgs = LightboxImage.getImages(imageUrls: list)
                let vc = LightboxController(images: imgs, startIndex: indexPath.row)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }
            if let url = (report?.target as? TalkModel)?.imageURL {
                let imgs = LightboxImage.getImages(imageUrls: [url])
                let vc = LightboxController(images: imgs, startIndex: 0)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }
            break
        default:
            break
        }
        
        switch dataTypes[indexPath.section][indexPath.row] {
        case .targetRegDt:
            if let model = report?.target as? ReviewModel {
                performSegue(withIdentifier: "showReviewHistory", sender: model.id)
            }
            if let model = report?.target as? TalkModel {
                let vc = TalkDetailTableViewController.viewController
                vc.documentId = model.id
                navigationController?.pushViewController(vc, animated: true)
            }
            break
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "showReviewHistory":
            if let vc = segue.destination as? ReviewHistoryTableViewController {
                vc.reviewId = sender as? String
            }
            break
        default:
            break
        }
    }
    
    
    
}
