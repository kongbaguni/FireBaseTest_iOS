//
//  StoresTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/11.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import RealmSwift
import RxSwift
import RxCocoa

class StoresTableViewController: UITableViewController {
    @IBOutlet weak var emptyView:EmptyView!
    @IBOutlet weak var updateDtLabel: UILabel!
    @IBOutlet weak var tableViewHeaderTitleLabel: UILabel!
    @IBOutlet weak var tableViewHeaderButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var footerBtn: UIButton!
    let disposebag = DisposeBag()
    var filterText:String? = nil

    
    var stores:Results<StoreModel> {
        var result = try! Realm().objects(StoreModel.self).sorted(byKeyPath: "name")
        if let txt = filterText {
            result = result.filter("name CONTAINS[c] %@ || addr CONTAINS[c] %@",txt,txt)
        }
        return result
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "mask now".localized
        searchBar.placeholder = "Search Store".localized
        emptyView.type = .wait
        emptyView.setTitle()
        if try! Realm().objects(StoreModel.self).count == 0 {
            onRefreshCongrol(UIRefreshControl())
        }
        self.refreshControl?.addTarget(self, action: #selector(self.onRefreshCongrol(_:)), for: .valueChanged)
        setTableStyle()
        emptyView.delegate = self
        emptyView.frame = view.frame
        emptyView.frame.size.height = view.frame.height - 100
        tableViewHeaderButton.setTitle("view on map".localized, for: .normal)
        setHeaderTitle()
        NotificationCenter.default.addObserver(forName: .deletedStoreModel, object: nil, queue: nil) { [weak self](_) in
            self?.tableView.reloadData()
            self?.onRefreshCongrol(UIRefreshControl())
        }
        try! Realm().refresh()
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
        
        if UserInfo.info != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupNavigationBarButton(_:)))
        }
        else {
            navigationItem.leftBarButtonItem =
                UIBarButtonItem(title: "close".localized, style: .plain, target: self, action: #selector(self.onTouchupCloseBtn(_:)))
        }
        
        footerBtn.setTitle("storeList footer btn title".localized, for: .normal)
        footerBtn.rx.tap.bind { (_) in
            let vc = WebViewController.viewController
            vc.title = "Food and Drug Administration Official Blog".localized
            vc.url = URL(string:"https://m.blog.naver.com/kfdazzang/221839489769")
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: self.disposebag)
    }
    
    @objc func onTouchupCloseBtn(_ sender:UIBarButtonItem) {
        if navigationController?.viewControllers.first == self {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.shared.manager.startUpdatingLocation()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocationManager.shared.manager.stopUpdatingLocation()
    }
    
    func getStoreList(type:StoreModel.RemainType)->Results<StoreModel> {
        return stores.filter("remain_stat == %@",type.rawValue).sorted(byKeyPath: "distance")
    }
    
    @IBAction func onTouchupViewOnMap(_ sender:UIButton) {
        var codes:[String] = []
        for store in stores {
            codes.append(store.code)
        }
        performSegue(withIdentifier: "showMap", sender: codes)
    }
    
    @objc func onRefreshCongrol(_ sender:UIRefreshControl)  {
        var cnt = 0
        ApiManager.shard.getStores { [weak self](count) in
            sender.endRefreshing()
            switch LocationManager.shared.authStatus {
            case .denied, .none:
                self?.emptyView.type = .locationNotAllow
            default:
                break
            }
            if cnt == 0 {
                self?.emptyView.type = .empty
                self?.setTableStyle()
                self?.tableView.reloadData()
                self?.setHeaderTitle()                
            }
            cnt += 1            
        }
    }
    
    @objc func onTouchupNavigationBarButton(_ sender:UIBarButtonItem) {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        vc.addAction(UIAlertAction(title: "myProfile".localized, style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "showProfile", sender: nil)
        }))
        if UserInfo.info?.email == "kongbaguni@gmail.com" {
            vc.addAction(UIAlertAction(title: "admin menu".localized, style: .default, handler: { (action) in
                let vc = AdminViewController.viewController
                self.navigationController?.pushViewController(vc, animated: true)
            }))
        }
        vc.addAction(UIAlertAction(title: "logout".localized, style: .default, handler: { (_) in
            UserInfo.info?.logout()
        }))
        vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        vc.popoverPresentationController?.barButtonItem = sender
        present(vc, animated: true, completion: nil)        
    }
    
    private func setHeaderTitle() {
        updateDtLabel.text = String(format: "update : %@".localized, stores.first?.updateDt.relativeTimeStringValue ?? "0")
        let number = stores.filter("remain_stat != %@ && remain_stat != %@ ","empty","break").count
        let searchDistance = stores.first?.searchDisance ?? UserInfo.info?.distanceForSearch ?? Consts.DISTANCE_STORE_SEARCH
        tableViewHeaderTitleLabel.text = String(format:"Where to buy masks near %@ meters: %@ places".localized, "\(searchDistance.decimalForamtString)", "\(number)")
    }
    
    private func setTableStyle() {
        if stores.count == 0 {
            tableView.separatorStyle = .none
            tableView.tableHeaderView?.isHidden = true
            view.addSubview(emptyView)
        } else {
            tableView.separatorStyle = .singleLine
            tableView.tableHeaderView?.isHidden = false
            emptyView.removeFromSuperview()
        }

    }
    
    func getSectionType(section:Int)->StoreModel.RemainType {
        switch section {
        case 0:
            return .plenty
        case 1:
            return .some
        case 2:
            return .few
        case 3:
            return .empty
        default:
            return .break
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if stores.count == 0 {
            return 0
        }
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStoreList(type: getSectionType(section: section)).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell") as! StoresTableViewCell
        
        let list = getStoreList(type: getSectionType(section: indexPath.section))
        if indexPath.row >= list.count {
            return UITableViewCell()
        }
        let data = list[indexPath.row]
        cell.storeId = data.code
        return cell
    }
        
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if stores.count == 0 {
            return nil
        }
        let type = getSectionType(section: section)
        let list = getStoreList(type: type)
        if list.count == 0 {
            return nil
        }
        let view = UIButton()
        view.backgroundColor = .autoColor_text_color
        view.setTitleColor(.autoColor_bg_color, for: .normal)        
        view.setTitle("\(list.first?.remain_stat.localized ?? "") \(list.count)", for: .normal)
        view.tag = section
        view.backgroundColor = type.colorValue
        view.addTarget(self, action: #selector(self.ontouchupFooterBtn(_:)), for: .touchUpInside)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if stores.count == 0 {
            return CGFloat.leastNormalMagnitude
        }
        let type = getSectionType(section: section)
        let list = getStoreList(type: type)
        if list.count == 0 {
            return CGFloat.leastNormalMagnitude
        }        
        return 30
    }
    
    @objc func ontouchupFooterBtn(_ sender:UIButton) {
        let list = getStoreList(type: getSectionType(section: sender.tag))
        var ids:[String] = []
        for shop in list {
            ids.append(shop.code)
        }
        performSegue(withIdentifier: "showMap", sender: ids)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = getStoreList(type: getSectionType(section: indexPath.section))
        if indexPath.row >= list.count {
            return
        }
        let data = list[indexPath.row]
        performSegue(withIdentifier: "showMap", sender: data.code)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showMap":
            if let vc = segue.destination as? MapViewController {
                if let value = sender as? String {
                    vc.storeCodes = [value]
                }
                else if let value = sender as? [String] {
                    vc.storeCodes = value
                }
            }
        case "showStoreStockLogs":
            if let vc = segue.destination as? StoreStockLogTableViewController {
                vc.code = sender as? String
            }
        case "showWaitting":
            if let vc = segue.destination as? StoreWaittingTableViewController {
                vc.storeId = sender as? String
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        "view on map" = "지도에서 보기";
//        "show stock log" = "재고 상황";
        let list = getStoreList(type: getSectionType(section: indexPath.section))
        let data = list[indexPath.row]
        let code = data.code
        let action1 = UIContextualAction(style: .normal, title: "view on map".localized) { (action, view, complete) in
            self.performSegue(withIdentifier: "showMap", sender: code)
        }
        action1.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1)
        let action2 = UIContextualAction(style: .normal, title: "show stock log".localized) { (action, view, complete) in
            self.performSegue(withIdentifier: "showStoreStockLogs", sender: code)
        }
        action2.backgroundColor = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1)
        
        let action3 = UIContextualAction(style: .normal, title: "show waitting log".localized) { (action, view, complete) in
            self.performSegue(withIdentifier: "showWaitting", sender: code)
        }
        action3.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.2, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [action1,action3,action2])
    }
        
}

extension StoresTableViewController : EmptyViewDelegate {
    func onTouchupButton(viewType: EmptyView.ViewType) {
        switch viewType {
        case .wait:
            break
        case .empty:
            self.onRefreshCongrol(self.refreshControl!)
        case .locationNotAllow:
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)

        }
    }
}
