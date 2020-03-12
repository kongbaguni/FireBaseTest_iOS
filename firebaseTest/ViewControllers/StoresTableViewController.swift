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

class StoresTableViewController: UITableViewController {
    @IBOutlet weak var emptyView:EmptyView!
    @IBOutlet weak var updateDtLabel: UILabel!
    @IBOutlet weak var tableViewHeaderTitleLabel: UILabel!
    @IBOutlet weak var tableViewHeaderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "mask now".localized
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
    }
    
    var stores:Results<StoreModel> {
        return try! Realm().objects(StoreModel.self).sorted(byKeyPath: "name")
    }
    
    func getStoreList(type:StoreModel.RemainType)->Results<StoreModel> {
        return stores.filter("remain_stat == %@",type.rawValue)
    }
    
    @IBAction func onTouchupViewOnMap(_ sender:UIButton) {
        let list = self.stores.filter("remain_stat != %@","empty")
        var codes:[String] = []
        for store in list {
            codes.append(store.code)
        }
        performSegue(withIdentifier: "showMap", sender: codes)
    }
    
    @objc func onRefreshCongrol(_ sender:UIRefreshControl)  {
        ApiManager.shard.getStores { [weak self](count) in
            sender.endRefreshing()
            self?.emptyView.type = count == nil ? .locationNotAllow : .empty
            self?.setTableStyle()
            self?.tableView.reloadData()
            self?.setHeaderTitle()
        }
    }
    
    private func setHeaderTitle() {
        updateDtLabel.text = String(format: "update : %@".localized, stores.first?.updateDt.relativeTimeStringValue ?? "0")
        let number = stores.filter("remain_stat != %@","empty").count
        tableViewHeaderTitleLabel.text = String(format:"Where to buy masks near %@ meters: %@ places".localized, "1000", "\(number)")
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
        default:
            return .empty
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if stores.count == 0 {
            return 0
        }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getStoreList(type: getSectionType(section: section)).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell") as! StoresTableViewCell
        
        let list = getStoreList(type: getSectionType(section: indexPath.section))
        let data = list[indexPath.row]
        cell.setData(data: data)
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
        view.backgroundColor = .text_color
        view.setTitleColor(.bg_color, for: .normal)        
        view.setTitle("\(list.first?.remain_stat.localized ?? "") \(list.count)", for: .normal)
        view.tag = section
        view.backgroundColor = type.colorValue
        view.addTarget(self, action: #selector(self.ontouchupFooterBtn(_:)), for: .touchUpInside)
        return view
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
        default:
            break
        }
    }
        
}

extension StoresTableViewController : EmptyViewDelegate {
    func onTouchupButton(viewType: EmptyView.ViewType) {
        switch viewType {
        case .empty:
            self.onRefreshCongrol(self.refreshControl!)
        case .locationNotAllow:
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)

        }
    }
}
