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

class TodaysTalksTableViewController: UITableViewController {
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
            result = result.filter("bettingPoint = %@",0)
        }
        
        if let txt = filterText {
            result = result.filter("textForSearch CONTAINS[c] %@", txt)
        }
        
        return result
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "todays talks".localized
        searchBar.placeholder = "text search".localized
        hideGameOptionLabel.text = "hide game talk".localized
        hideGameOptionSwitch.isOn = UserDefaults.standard.isHideGameTalk
        nearTalkOptionLabel.text = "show near talk".localized
        nearTalkOptionSwitch.isOn = UserDefaults.standard.isShowNearTalk
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupMenuBtn(_:)))
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
                self?.tableView.reloadData()
            }).disposed(by: self.disposebag)
        
        toolBar.items = [
            UIBarButtonItem(title: "write talk".localized, style: .plain, target: self, action: #selector(self.onTouchupAddBtn(_:))),
        ]
        hideGameOptionView.isHidden = AdminOptions.shared.canPlayPoker == false
        
        headerStackView.frame.size.height = AdminOptions.shared.canPlayPoker ? 130 : 90
        if AdminOptions.shared.canPlayPoker {
            toolBar.items?.append(UIBarButtonItem(title: "Poker".localized, style: .plain, target: self, action: #selector(self.onTouchupCardGame(_:))))

            hideGameOptionSwitch.rx.isOn.subscribe { (event) in
                UserDefaults.standard.isHideGameTalk = self.hideGameOptionSwitch.isOn
                self.tableView.reloadData()
                self.toolBar.items?.last?.isEnabled = !self.hideGameOptionSwitch.isOn
            }.disposed(by: self.disposebag)
        }
        
        nearTalkOptionSwitch.rx.isOn.subscribe { (event) in
            UserDefaults.standard.isShowNearTalk = self.nearTalkOptionSwitch.isOn
            self.tableView.reloadData()
        }.disposed(by: self.disposebag)
        
        NotificationCenter.default.addObserver(forName: .game_usePointAndGetExpNotification, object: nil, queue: nil) { [weak self](notification) in
            func showStatus(change:StatusChange) {
                if self?.presentingViewController == nil {
                    let vc = StatusViewController.viewController
                    vc.statusChange = change
                    vc.userId = UserInfo.info?.id
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
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in [nearTalkOptionSwitch, hideGameOptionSwitch] {
            view?.onTintColor = .autoColor_switch_color
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.onRefreshControl(UIRefreshControl())
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
        UserInfo.info?.syncData(complete: { (_) in
            TalkModel.syncDatas {
                sender.endRefreshing()
                self.tableView.reloadData()
                if self.isNeedScrollToBottomWhenRefresh {
                    let number = self.tableView.numberOfRows(inSection: 0)
                    if oldCount != number {
                        self.tableView.scrollToRow(at: IndexPath(row: number - 1, section: 0), at: .middle, animated: true)
                    }
                    self.isNeedScrollToBottomWhenRefresh = false
                }
                if let index = self.needScrolIndex {
                    self.tableView.scrollToRow(at: index, at: .middle, animated: true)
                    self.needScrolIndex = nil
                }
            }
        })

    }
    
    @objc func onTouchupCardGame(_ sender:UIBarButtonItem) {
        let vc = HoldemViewController.viewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)

//        let gameCount = UserInfo.info?.todaysMyGameCount ?? 0
//        if gameCount > Consts.MAX_GAME_COUNT {
//            debugPrint("game count : \(gameCount)")
//            Toast.makeToast(message: "game count limit over msg".localized)
//            return
//        }
//        let ac = UIAlertController(title: nil, message: "game select", preferredStyle: .actionSheet)
//        ac.addAction(UIAlertAction(title: "simple porker", style: .default, handler: { (action) in
//            self.playSimplePorker()
//        }))
//        ac.addAction(UIAlertAction(title: "holdem", style: .default, handler: { (action) in
//            let vc = HoldemViewController.viewController
//            vc.delegate = self
//            self.present(vc, animated: true, completion: nil)
//        }))
//        ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
//        present(ac, animated: true, completion: nil)
    }
    
    private func playSimplePorker() {
        let msg = String(format:"betting point input.\nmy point : %@".localized, (UserInfo.info?.point ?? 0).decimalForamtString )
        let vc = UIAlertController(title: "Porker", message: msg, preferredStyle: .alert)
        let lastBetting = try! Realm().objects(TalkModel.self).filter("creatorId = %@ && bettingPoint > 0",UserInfo.info!.id).last?.bettingPoint ?? UserInfo.info!.point / 10
        vc.addTextField { (textFiled) in
            textFiled.text = "\(lastBetting)"
            textFiled.keyboardType = .numberPad
            textFiled
                .rx.text.orEmpty.subscribe(onNext: { (query) in
                    let up = UserInfo.info?.point ?? 0
                    let number = NSString(string: query).integerValue
                    if number > Consts.BETTING_LIMIT {
                        textFiled.text = "\(Consts.BETTING_LIMIT)"
                    }
                    else if number > up {
                        textFiled.text = "\(up)"
                    } else {
                        textFiled.text = "\(number)"
                    }
                }).disposed(by: self.disposebag)
        }
        vc.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { [weak vc] (action) in
            guard let text = vc?.textFields?.first?.text else {
                return
            }
            let betting = NSString(string:text).integerValue
            if betting == 0 {
                return
            }
            GameManager.shared.playPokerGame(useJoker: false, bettingPoint: betting) { [weak self](isSucess) in
                if let s = self {
                    s.tableView.reloadData()
                    let number = s.tableView.numberOfRows(inSection: 0)
                    s.tableView.scrollToRow(at: IndexPath(row: number - 1, section: 0), at: .middle, animated: true)
                }
            }
        }))
        vc.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
    
    
    @objc func onTouchupMenuBtn(_ sender:UIBarButtonItem) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "myProfile".localized, style: .default, handler: { (action) in
            self.navigationController?.performSegue(withIdentifier: "showMyProfile", sender: nil)
        }))
        
        if UserInfo.info?.email == "kongbaguni@gmail.com" {
            vc.addAction(UIAlertAction(title: "admin menu".localized, style: .default, handler: { (action) in
                let vc = AdminViewController.viewController
                self.navigationController?.pushViewController(vc, animated: true)
            }))
        }
        
        vc.addAction(UIAlertAction(title: "write talk".localized, style: .default, handler: { (action) in
            self.isNeedScrollToBottomWhenRefresh = true
            self.performSegue(withIdentifier: "showTalk", sender: nil)
        }))
        
        vc.addAction(UIAlertAction(title: "logout".localized, style: .default, handler: { (action) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
                return
            }
            
            UserInfo.info?.logout()
        }))
        
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
    
    @objc func onTouchupAddBtn(_ sender:UIBarButtonItem) {
        
        self.isNeedScrollToBottomWhenRefresh = true
        self.performSegue(withIdentifier: "showTalk", sender: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = list[indexPath.row]
        if data.holdemResult != nil {
            let cellId = data.creatorId == UserInfo.info?.id ? "myHoldemCell" : "holdemCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TalkDetailHoldemTableViewCell
            
            cell.talkId = data.id
            
            return cell
        }
        if data.cardSet != nil {
            let cellId = data.creatorId == UserInfo.info?.id ? "myCardCell" : "cardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TalkDetailCardTableViewCell
            cell.talkId = data.id            
            return cell
        }
        
        if data.imageURL != nil {
            let cellId = data.creatorId == UserInfo.info?.id ? "myImageCell" : "imageCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodayTalksTableImageViewCell
            cell.setData(data: list[indexPath.row])
            return cell
        }
        
        let cellId = data.creatorId == UserInfo.info?.id ? "myCell" : "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodayTalksTableViewCell
        cell.setData(data: list[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let talk = list[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: talk.id)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let model = list[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "like", handler: { (action, view, complete) in
            model.toggleLike()
            model.update { (sucess) in
                complete(true)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
//                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        })
        action.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.15, alpha: 1)
        let iconRed =  #imageLiteral(resourceName: "heart").af.imageAspectScaled(toFit: CGSize(width: 20, height: 20))
                      
        let iconWhite =  iconRed.withTintColor(.white)
        action.image = model.isLike ? iconRed : iconWhite
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let data = list[indexPath.row]
        var actions:[UIContextualAction] = []
        if data.creatorId == UserInfo.info?.id && data.cardSet == nil {
            let action = UIContextualAction(style: .normal, title: "edit".localized, handler: { [weak self](action, view, complete) in
                if let data = self?.list[indexPath.row] {
                    self?.needScrolIndex = indexPath
                    self?.performSegue(withIdentifier: "showTalk", sender: data.id)
                }
            })
            action.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1)
            actions.append(
                action
            )
        }
        let detailAction = UIContextualAction(style: .normal, title: "detail View".localized, handler: { [weak self] (action, view, complete)  in
            if let talk = self?.list[indexPath.row] {
                self?.performSegue(withIdentifier: "showDetail", sender: talk.id)
            }
        })
        detailAction.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.6, alpha: 1)
        actions.append(detailAction)
        return UISwipeActionsConfiguration(actions: actions)
    }
 
}


extension TodaysTalksTableViewController : HoldemViewControllerDelegate {
    func didGameFinish(isBettingGame: Bool) {
        if isBettingGame {
            self.tableView.reloadData()
        }
    }
    
    
}
