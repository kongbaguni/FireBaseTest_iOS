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
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "mask now".localized
        LocationManager.shared.requestAuth {
            LocationManager.shared.manager.startUpdatingLocation()
            NotificationCenter.default.addObserver(forName: .locationUpdateNotification, object: nil, queue: nil) {
                [weak self] (notification) in
                if let locations = notification.object as? [CLLocation] {
                    for location in locations {
                        if self?.requestCount == 0 {
                            self?.requestStoreInfo(coordinate: location.coordinate)
                        }
                    }
                    
                }
            }
        }
    }
    var requestCount = 0
    
    var stores:Results<StoreModel> {
        return try! Realm().objects(StoreModel.self).sorted(byKeyPath: "name")
    }
    
    func getStoreList(type:StoreModel.RemainType)->Results<StoreModel> {
        return stores.filter("remain_stat == %@",type.rawValue)
    }
    
    func requestStoreInfo(coordinate:CLLocationCoordinate2D)  {
        requestCount += 1
        ApiManager().getStores(lat: coordinate.latitude, lng: coordinate.longitude) { [weak self](number) in
            print(number ?? "실패")
            self?.tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getSectionType(section: section).rawValue.localized
    }
}
