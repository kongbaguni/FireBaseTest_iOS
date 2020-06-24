//
//  InAppPurchesTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/19.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import StoreKit
import RxCocoa
import RxSwift
import SwiftyStoreKit
import RealmSwift

class InAppPurchesTableViewController: UIViewController {
    let loading = Loading()
    struct ProductData {
        let id:String
        let title:String
    }
    
    var products:Results<InAppPurchaseModel> {
        return try! Realm().objects(InAppPurchaseModel.self).sorted(byKeyPath: "price")
    }
    
    var productIdSet:Set<String> { InAppPurchase.productIdSet }
    
    static var viewController : InAppPurchesTableViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "InAppPurchase", bundle: nil).instantiateViewController(identifier: "list")
        } else {
            return UIStoryboard(name: "InAppPurchase", bundle: nil).instantiateViewController(withIdentifier: "list") as! InAppPurchesTableViewController
        }
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var closeBtn:UIButton!
    @IBOutlet weak var verifyPurchaseBtn: UIButton!
    
    let disposebag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.setBorder(borderColor: .autoColor_text_color, borderWidth: 0.5, radius: 10, masksToBounds: true)
        titleLabel.text = "in app Purchase title".localized
        closeBtn.rx.tap.bind { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposebag)

        verifyPurchaseBtn.setTitle("Restore purchase".localized, for: .normal)
        verifyPurchaseBtn.rx.tap.bind { [weak self] (_) in
            guard let s = self else {
                return
            }
            s.loading.show(viewController: s)
            InAppPurchase.restorePurchases() { [weak s] (isSucess) in
                s?.loading.hide()
                if isSucess {
                    s?.tableView.reloadData()
                }
            }
            
        }.disposed(by: disposebag)
//        verifyPurchase()
    }
}

extension InAppPurchesTableViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InAppPurchesTableViewCell
        let product = products[indexPath.row]
        cell.productId = product.id
        cell.titleLabel.text = product.title
        cell.descLabel.text = product.desc
        cell.priceLabel.text = product.localeFormatedPrice
        cell.contentView.alpha = product.isPurchase ? 0.3 : 1
        return cell
    }
}

extension InAppPurchesTableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        InAppPurchase.buyProduct(productId: product.id) { (sucess) in
            if sucess {
                self.tableView.reloadData()
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class InAppPurchesTableViewCell : UITableViewCell {
    var productId:String = ""
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var descLabel:UILabel!
    @IBOutlet weak var priceLabel:UILabel!
}
