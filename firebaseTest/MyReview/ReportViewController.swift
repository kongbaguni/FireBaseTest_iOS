//
//  ReportViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/06/18.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ReportViewController: UIViewController {
    static var viewController:ReportViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(identifier: "report")
        } else {
            return UIStoryboard(name: "MyReview", bundle: nil).instantiateViewController(withIdentifier: "report") as! ReportViewController
        }
    }
    private var selectedResonType:ReportModel.ResonType? = nil
    private var reson:String? = nil
    
    private var targetId:String? = nil
    private var targetType:ReportModel.TargetType? = nil
    
    func setData(targetId:String, targetType:ReportModel.TargetType) {
        self.targetType = targetType
        self.targetId = targetId
    }
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var descLabel:UILabel!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "report".localized
        descLabel.text = "Please enter a reason for reporting".localized
        confirmBtn.setTitle("report".localized, for: .normal)
        
        closeBtn.rx.tap.bind {[weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        confirmBtn.rx.tap.bind { [weak self](_) in
            self?.report()
        }.disposed(by: disposeBag)
        
        contentView.setBorder(borderColor: .autoColor_text_color, borderWidth: 0.5, radius: 10, masksToBounds: true)
    }
    
    func report() {
        if self.selectedResonType == nil {
            self.alert(title: nil, message: "select reson".localized)
            return
        }
        
        ReportModel.create(
            targetId: self.targetId!,
            targetType: self.targetType!,
            resonType: self.selectedResonType!,
            reson: self.reson ?? "") { [weak self](sucess) in
                if sucess {
                    self?.alert(title: nil, message: "report sucess".localized, confirmText: "confirm".localized, didConfirm: { (_) in
                        self?.dismiss(animated: true, completion: nil)
                    })
                }
        }
    }
}


extension ReportViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportModel.ResonType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ReportModel.ResonType.allCases[indexPath.row].rawValue.localized
        return cell
    }
    
}

extension ReportViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedResonType = ReportModel.ResonType.allCases[indexPath.row]
        if selectedResonType == .other {
            let vc = UIAlertController(title: nil, message: "input reson".localized, preferredStyle: .alert)
            vc.addTextField { (textField) in
                textField.rx.text.orEmpty.bind { (string) in
                    self.reson = string
                    print(self.reson ?? "none")
                }.disposed(by: self.disposeBag)
            }
            vc.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (action) in
                self.report()
            }))
            vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            present(vc, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedResonType = nil
    }
}
