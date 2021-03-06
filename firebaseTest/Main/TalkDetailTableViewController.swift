//
//  TalkDetailTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/10.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class TalkDetailTableViewController: UITableViewController {
    static var viewController:TalkDetailTableViewController {
        let storeyBoard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            return storeyBoard.instantiateViewController(identifier: "talkDetail") as! TalkDetailTableViewController
        } else {
            return storeyBoard.instantiateViewController(withIdentifier: "talkDetail") as! TalkDetailTableViewController
        }
    }
    let disposeBag = DisposeBag()
    
    let loading = Loading()
    
    var documentId:String? = nil
    
    var talkModel:TalkModel? {
        if let id = documentId {
            return try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id)
        }
        return nil
    }
    @IBOutlet weak var likeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "detail View".localized
        
        if let id = talkModel?.creatorId {
            if try! Realm().object(ofType: UserInfo.self, forPrimaryKey: id) == nil {
                UserInfo.getUserInfo(id: id) { [weak self](sucess) in
                    if sucess {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupNaviBarButton(_:)))
        self.talkModel?.readDetail(complete: { (sucess) in
            
        })
        
        NotificationCenter.default.addObserver(forName: .likeUpdateNotification, object: nil, queue: nil) { [weak self] (_) in
            self?.tableView.reloadData()
        }

        likeBtn.setTitle("processing...".localized, for: .disabled)
        likeBtn.setTitleColor(.autoColor_weak_text_color, for: .disabled)
        likeBtn.rx.tap.bind { [weak self](_) in
            self?.likeBtn.isEnabled = false
            self?.talkModel?.toggleLike(complete: { (isSucess) in
                self?.likeBtn.isEnabled = true
                self?.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
                self?.setData()
            })
        }.disposed(by: disposeBag)
        setData()
        
    }
    
    private func setData() {
        guard let talk = talkModel else {
            return
        }
        
        let format = talk.isLike ? "liked : %@" : "like : %@"
        let str = String(format:format.localized, talk.likes.count.decimalForamtString)
        
        likeBtn.setTitleColor(talk.isLike ? .autoColor_bold_text_color : .autoColor_text_color , for: .normal)
        likeBtn.setTitle(str, for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
        
    @objc func onTouchupNaviBarButton(_ sender:UIBarButtonItem) {
        guard
            let talkId = self.talkModel?.id,
            let userId = self.talkModel?.creatorId else {
                return
        }

        let isLike = self.talkModel?.isLike ?? false
        
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.popoverPresentationController?.barButtonItem = sender
        vc.addAction(UIAlertAction(title: isLike ? "like cancel".localized : "like".localized, style: .default, handler: { (action) in
            self.loading.show(viewController: self)
            self.talkModel?.toggleLike(complete: { [weak self] (isLike) in
                self?.loading.hide()
                self?.tableView.reloadData()
            })
        }))
                

        if self.talkModel?.creatorId == UserInfo.info?.id {
            vc.addAction(UIAlertAction(title: "edit".localized, style: .default, handler: { (action) in
                let vc = PostTalkViewController.viewController
                vc.documentId = talkId
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            
            vc.addAction(UIAlertAction(title: "delete talk title".localized, style: .default, handler: { (action) in
                let msg = String(format : "delete talk msg %@".localized, AdminOptions.shared.pointUseDeleteTalk.decimalForamtString)
                
                let ac = UIAlertController(title: "delete talk title".localized, message: msg, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                
                ac.addAction(UIAlertAction(title: "delete".localized, style: .default, handler: { (action) in
                    func deleteAction() {
                        if UserInfo.info?.point ?? 0 < AdminOptions.shared.pointUseDeleteTalk {
                            GameManager.shared.showAd(popoverView: sender) {
                                deleteAction()
                            }
                        } else {
                            let model = try! Realm().object(ofType: TalkModel.self, forPrimaryKey: talkId)
                            model?.delete(){[weak self] (sucess) in
                                if sucess {
                                    if self?.navigationController?.viewControllers.first == self {
                                        self?.dismiss(animated: true, completion: nil)
                                    } else {
                                        self?.navigationController?.popViewController(animated: true)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                        let vc = StatusViewController.viewController(withUserId: userId)
                                        vc.statusChange = StatusChange(addedExp: 0, pointChange: -AdminOptions.shared.pointUseDeleteTalk)
                                        UIApplication.shared.lastViewController?.present(vc, animated: true, completion: nil)
                                    }
                                }
                                else {
                                    Toast.makeToast(message: "delete talk fail msg".localized)
                                }
                            }
                        }
                    }
                    deleteAction()
                }))
                self.present(ac, animated: true, completion: nil)
                
            }))
        }
        else {
            if let docuId = self.documentId {
                vc.addAction(UIAlertAction(title: "report".localized, style: .default, handler: { (_) in
                    let vc = ReportViewController.viewController
                    vc.setData(targetId: docuId, targetType: .talk)
                    self.present(vc, animated: true, completion: nil)
                }))
            }
        }
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showUserInfoDetail":
            if
                let id = sender as? String,
                let vc = segue.destination as? UserInfoDetailViewController {
                vc.userId = id
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return (talkModel?.editList.count ?? 0) + 1
        case 2:
            return talkModel?.likes.count ?? 0
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo") as! TalkDetailUserInfoTableViewCell
            
            if let userid = talkModel?.creatorId {
                cell.userId = userid
            }
            
            return cell
        case 1:
            if talkModel?.gameResultBase64encodingSting.isEmpty == false  {
                if talkModel?.holdemResult != nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "holdem", for: indexPath) as! TalkDetailEditHistoryHoldemTableViewCell
                    cell.talkId = talkModel?.id
                    return cell                    
                }
                return UITableViewCell()
            }
            if let editList = talkModel?.editList {
                if indexPath.row == 0 {
                    if let str = talkModel?.imageThumbURLstr {
                        if let imgUrl = URL(string: str) {
                            let cell = tableView.dequeueReusableCell(withIdentifier: "editHistoryImage") as! TalkDetailEditHistoryImageTableViewCell
                            cell.dateLabel.text = talkModel?.regDt.simpleFormatStringValue
                            cell.textView.text = talkModel?.text
                            cell.attachmentImageView.kf.setImage(with: imgUrl, placeholder: UIImage.placeHolder_image)
                            return cell
                        }
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: "editHistory") as! TalkDetailEditHistoryTableViewCell
                    cell.dateLabel.text = talkModel?.regDt.simpleFormatStringValue
                    cell.textView.text = talkModel?.text
                    return cell
                }
                let data = editList[indexPath.row - 1]
                if data.imageUrl != nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "editHistoryImage") as! TalkDetailEditHistoryImageTableViewCell
                    cell.editLogID = data.id
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "editHistory") as! TalkDetailEditHistoryTableViewCell
                    cell.editLogID = data.id
                    return cell
                }
            }
            return UITableViewCell()
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userInfo") as! TalkDetailUserInfoTableViewCell
            if let likeList = talkModel?.likes {
                cell.likeId = likeList[indexPath.row].id
            }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "map") as! TalkDetailMapTableViewCell
            cell.location = talkModel?.location
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "creator".localized
        case 1:
            if talkModel?.gameResultBase64encodingSting.isEmpty == false {
                return "game result".localized
            }
            return "edit history".localized
        case 2:
            if talkModel?.likes.count == 0 {
                return nil
            }
            return "like peoples".localized
        case 3:
            return "posting location".localized
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let vc = StatusViewController.viewController(withUserId: self.talkModel?.creatorId)
            present(vc, animated: true, completion: nil)
        //            performSegue(withIdentifier: "showUserInfoDetail", sender: self.talkModel?.creatorId)
        case 1:
            switch indexPath.row {
            case 0:
                let vc = PopupMapViewController.viewController(
                    coordinate: talkModel?.cordinate,
                    title: talkModel?.regDt.simpleFormatStringValue,
                    annTitle: "posting location".localized )
                present(vc, animated: true, completion: nil)
            default:
                if let editList = talkModel?.editList {
                    let data = editList[indexPath.row - 1]
                    let vc = PopupMapViewController.viewController(
                        coordinate: data.cordinate,
                        title: data.regDt.simpleFormatStringValue,
                        annTitle: "editing location".localized
                    )
                    present(vc, animated: true, completion: nil)
                }
            }
        case 2:
            if let likes = talkModel?.likes {
                let id = likes[indexPath.row].creatorId
                let vc = StatusViewController.viewController(withUserId: id)
                present(vc, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
}
