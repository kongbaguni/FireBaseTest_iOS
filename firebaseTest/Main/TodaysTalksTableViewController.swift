//
//  TodaysTalksTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/06.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RealmSwift
import AlamofireImage
import RxSwift
import RxCocoa
import FirebaseAuth
import Lightbox

class TodaysTalksTableViewController: UITableViewController {
    static var viewController : TodaysTalksTableViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "todaysTalks") as! TodaysTalksTableViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "todaysTalks") as! TodaysTalksTableViewController
        }
    }
    
    var filterText:String? = nil
    var list:Results<TalkModel> {
        var result = try! Realm().objects(TalkModel.self)
            .sorted(byKeyPath: "regTimeIntervalSince1970", ascending: true)
            .filter("regTimeIntervalSince1970 > %@", Date.midnightTodayTime.timeIntervalSince1970)
        
        if UserDefaults.standard.isShowNearTalk {
            if let myLocation = UserDefaults.standard.lastMyCoordinate {
                let minlat = myLocation.latitude - 0.005
                let maxlat = myLocation.latitude + 0.005
                let minlng = myLocation.longitude - 0.005
                let maxlng = myLocation.longitude + 0.005
                result = result.filter("lat > %@ && lat < %@ && lng > %@ && lng < %@",minlat, maxlat, minlng, maxlng)
            }
        }
        if UserDefaults.standard.isHideGameTalk {
            result = result.filter("gameResultBase64encodingSting = %@","")
        }
        
        if let txt = filterText {
            result = result.filter("textForSearch CONTAINS[c] %@", txt)
        }
        
        return result
    }
    
    var notices:Results<NoticeModel> {
        return try! Realm().objects(NoticeModel.self).sorted(byKeyPath: "updateDtTimeinterval1970", ascending: false).filter("isShow = %@ && isRead = %@",true,false)
    }
    
    let disposebag = DisposeBag()
    
    var isNeedScrollToBottomWhenRefresh = false
    var needScrolIndex:IndexPath? = nil
    @IBOutlet weak var headerStackView:UIStackView!
    @IBOutlet weak var toolBar:UIToolbar!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var hideGameOptionView: UIView!
    @IBOutlet weak var hideGameOptionLabel: UILabel!
    @IBOutlet weak var hideGameOptionSwitch : UISwitch!
    
    @IBOutlet weak var nearTalkOptionLabel: UILabel!
    @IBOutlet weak var nearTalkOptionSwitch: UISwitch!
    
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet var emptyView: UIView!
    
    @IBOutlet weak var emptyViewWriteBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyViewLabel.text = "todays talk desc".localized
        emptyViewWriteBtn.setTitle("write talk".localized, for: .normal)
        title = "todays talks".localized
        searchBar.placeholder = "text search".localized
        hideGameOptionLabel.text = "hide game talk".localized
        hideGameOptionSwitch.isOn = UserDefaults.standard.isHideGameTalk
        nearTalkOptionLabel.text = "show near talk".localized
        nearTalkOptionSwitch.isOn = UserDefaults.standard.isShowNearTalk
        if list.count == 0 {
            tableView.addSubview(emptyView)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(self.onTouchupMenuBtn(_:)))
        refreshControl?.addTarget(self, action: #selector(self.onRefreshControl(_:)), for: .valueChanged)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        searchBar
            .rx.text
            .orEmpty
            .subscribe(onNext: { [weak self](query) in
                print(query)
                let q = query.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                if q.isEmpty == false {
                    self?.filterText = q
                } else {
                    self?.filterText = nil
                }
                self?.reload()
            }).disposed(by: self.disposebag)
        
        toolBar.items = []
        toolBar.items?.append(UIBarButtonItem(
            title: "write talk".localized,
            style: .plain,
            target: self,
            action: #selector(self.onTouchupAddBtn(_:))))
        
        hideGameOptionView.isHidden = AdminOptions.shared.canPlayPoker == false
        
        headerStackView.frame.size.height = AdminOptions.shared.canPlayPoker ? 130 : 90
        if AdminOptions.shared.canPlayPoker {
            toolBar.items?.append(UIBarButtonItem(title: "Poker".localized, style: .plain, target: self, action: #selector(self.onTouchupCardGame(_:))))

            hideGameOptionSwitch.rx.isOn.subscribe { (event) in
                UserDefaults.standard.isHideGameTalk = self.hideGameOptionSwitch.isOn
                self.reload()
                self.toolBar.items?.last?.isEnabled = !self.hideGameOptionSwitch.isOn
            }.disposed(by: self.disposebag)
        }
        
        nearTalkOptionSwitch.rx.isOn.subscribe { (event) in
            UserDefaults.standard.isShowNearTalk = self.nearTalkOptionSwitch.isOn
            self.reload()
        }.disposed(by: self.disposebag)
        
        NotificationCenter.default.addObserver(forName: .game_usePointAndGetExpNotification, object: nil, queue: nil) { [weak self](notification) in
            func showStatus(change:StatusChange) {
                if self?.presentingViewController == nil {
                    let vc = StatusViewController.viewController(withUserId: UserInfo.info?.id)
                    vc.statusChange = change
                    self?.present(vc, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        showStatus(change: change)
                    }
                }
            }
            if let change = notification.object as? StatusChange {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                    showStatus(change: change)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: .postTalkNotification, object: nil, queue: nil) { [weak self] (notification) in
//            userInfo:["talkId":id,"point":point]
            if let needPoint = notification.userInfo?["point"] as? Int {
                let vc = StatusViewController.viewController(withUserId: UserInfo.info!.id)
                vc.statusChange = StatusChange(addedExp: needPoint, pointChange: -needPoint)
                self?.present(vc, animated: true, completion: nil)
                
                if let id = notification.userInfo?["talkId"] as? String {
                    if let model = try! Realm().object(ofType: TalkModel.self, forPrimaryKey: id) {
                        if let idx = self?.list.lastIndex(of: model) {
                            let indexPath = IndexPath(row: idx, section: 1)
                            self?.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                self?.tableView.deselectRow(at: indexPath, animated: true)
                            }
                            return
                        }
                    }
                }
            }
            self?.scrollToBottom()
        }
        NotificationCenter.default.addObserver(forName: .noticeUpdateNotification, object: nil, queue: nil) {[weak self] (notification) in
            if self?.notices.count ?? 0 == 0 {
                if self?.list.count ?? 0 > 0 {
                    self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
                }
                self?.reload()
            } else {
                self?.tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        NotificationCenter.default.addObserver(forName: .talkUpdateNotification, object: nil, queue: nil) {[weak self] (_) in
            self?.reload()
            self?.emptyView.isHidden = self?.list.count != 0 || self?.notices.count != 0
        }
        
        NotificationCenter.default.addObserver(forName: .todayTlakImageBtnTouchup, object: nil, queue: nil) {[weak self] (notification) in
            if let imglist = self?.list.filter("imageThumbURLstr != %@",""),                
                let noti_url = notification.object as? URL {
                var urls:[URL] = []
                var images:[LightboxImage] = []
                var sIndex:Int = 0
                for (index,talk) in imglist.enumerated() {
                    if let url = talk.imageURL {
                        urls.append(url)
                        let image = LightboxImage(imageURL: url, text: talk.text, videoURL: nil)
                        images.append(image)
                        if url == noti_url {
                            sIndex = index
                        }
                    }
                }
                
                let vc = LightboxController(images: images, startIndex: sIndex)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true, completion: nil)
            }
                
        }
        onRefreshControl(UIRefreshControl())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in [nearTalkOptionSwitch, hideGameOptionSwitch] {
            view?.onTintColor = .autoColor_switch_color
        }
        emptyView.setEmptyViewFrame()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshControl?.endRefreshing()
    }
    
    func reload() {
        emptyView.isHidden = list.count > 0 || notices.count != 0
        emptyView.layer.zPosition = 10
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTalk":
            if let id =  sender as? String, let vc = segue.destination as? PostTalkViewController  {
                vc.documentId  = id
            }
        case "showDetail":
            if let id = sender as? String,
                let vc = segue.destination as? TalkDetailTableViewController {
                vc.documentId = id
            }
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc func onRefreshControl(_ sender:UIRefreshControl) {
        let oldCount = self.tableView.numberOfRows(inSection: 0)
        TalkModel.syncDatas { [weak self] (isSucess) in
            if isSucess {
                NoticeModel.syncNotices { (isSucess) in
                    sender.endRefreshing()
                    if isSucess {
                        self?.reload()
                    }
                }
            } else {
                sender.endRefreshing()
            }
            
            self?.emptyView.isHidden = self?.list.count != 0 || self?.notices.count != 0
            self?.reload()
            if self?.isNeedScrollToBottomWhenRefresh == true {
                if let number = self?.tableView.numberOfRows(inSection: 0) {
                    if oldCount != number {
                        self?.scrollToBottom()
                    }
                    self?.isNeedScrollToBottomWhenRefresh = false
                }
            }
            if let index = self?.needScrolIndex {
                self?.tableView.scrollToRow(at: index, at: .middle, animated: true)
                self?.needScrolIndex = nil
            }
        }
    }
    
    func scrollToBottom() {
        reload()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {[weak self] in
            self?.tableView.scrollTableViewToBottom(animated: true)
        }
    }
    
    @objc func onTouchupCardGame(_ sender:UIBarButtonItem) {
        let vc = HoldemViewController.viewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func onTouchupMenuBtn(_ sender:UIBarButtonItem) {
        self.navigationController?.pushViewController(MyMenuViewController.viewController, animated: true)
    }
    
    @IBAction func onTouchupWriteBtn(_ sender: UIButton) {
        self.isNeedScrollToBottomWhenRefresh = true
        self.performSegue(withIdentifier: "showTalk", sender: nil)
    }
    
    @objc func onTouchupAddBtn(_ sender:UIBarButtonItem) {
        self.isNeedScrollToBottomWhenRefresh = true
        self.performSegue(withIdentifier: "showTalk", sender: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return notices.count
        case 1:
            return list.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "notice", for: indexPath)
            let notice = notices[indexPath.row]
            cell.textLabel?.text = notice.title
            return cell
        case 1:
            if indexPath.row >= list.count {
                return UITableViewCell()
            }
            
            let data = list[indexPath.row]
            if data.holdemResult != nil {
                let cellId = data.creatorId == UserInfo.info?.id ? "myHoldemCell" : "holdemCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TalkDetailHoldemTableViewCell
                
                cell.talkId = data.id
                
                return cell
            }
            
            if data.imageURL != nil && data.isDeletedByAdmin == false {
                let cellId = data.creatorId == UserInfo.info?.id ? "myImageCell" : "imageCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodayTalksTableImageViewCell
                cell.talkId = list[indexPath.row].id
                return cell
            }
            
            let cellId = data.creatorId == UserInfo.info?.id ? "myCell" : "cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodayTalksTableViewCell
            cell.talkId = list[indexPath.row].id
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if notices.count == 0 {
                return nil
            }
            return "notice".localized
        case 1:
            if list.count == 0 {
                return nil
            }
            return "talks".localized
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let vc = NoticeViewController.viewController
            vc.noticeId = notices[indexPath.row].id
            self.tabBarController?.present(vc, animated: true, completion: nil)
            
        case 1:
            let talk = list[indexPath.row]
            if talk.isDeleted == false && talk.isDeletedByAdmin == false {
                performSegue(withIdentifier: "showDetail", sender: talk.id)
            }
        
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 1:
            let data = list[indexPath.row]
            return data.isDeleted == false
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
//        let model = list[indexPath.row]
//        let action = UIContextualAction(style: .normal, title: "like".localized, handler: { (action, view, actionComplete) in
//            model.toggleLike {[weak self] (isLike) in
//                actionComplete(true)
//                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
//        })
//        action.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.15, alpha: 1)
//        let iconRed =  #imageLiteral(resourceName: "heart").af.imageAspectScaled(toFit: CGSize(width: 20, height: 20))
//
//        if #available(iOS 13.0, *) {
//            let iconWhite =  iconRed.withTintColor(.white)
//            action.image = model.isLike ? iconRed : iconWhite
//        } else {
//            action.image = model.isLike ? iconRed : nil
//        }
//
//
//        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let data = list[indexPath.row]
        if data.isDeleted || data.isDeletedByAdmin {
            return UISwipeActionsConfiguration(actions: [])
        }
        
        var actions:[UIContextualAction] = []
        if data.gameResultBase64encodingSting.isEmpty == true  {
            if data.creatorId == UserInfo.info?.id {
                let action = UIContextualAction(style: .normal, title: "edit".localized, handler: { [weak self](action, view, complete) in
                    if let data = self?.list[indexPath.row] {
                        self?.needScrolIndex = indexPath
                        self?.performSegue(withIdentifier: "showTalk", sender: data.id)
                    }
                })
                action.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1)
                actions.append(action)
            } else {
                let action = UIContextualAction(style: .destructive, title: "report".localized) { [weak self](action, view, complete) in
                    let vc = ReportViewController.viewController
                    vc.setData(targetId: data.id, targetType: .talk)
                    self?.present(vc, animated: true, completion: nil)
                }
                actions.append(action)
            }
        }
////        let detailAction = UIContextualAction(style: .normal, title: "detail View".localized, handler: { [weak self] (action, view, complete)  in
////            if let talk = self?.list[indexPath.row] {
////                self?.performSegue(withIdentifier: "showDetail", sender: talk.id)
////            }
////        })
//        detailAction.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.6, alpha: 1)
//        actions.append(detailAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
 
}
