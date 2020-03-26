//
//  TalkHistoryTableViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/26.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxCocoa
import RxSwift
/** 대화 작성 이력 보여주는 뷰 컨트롤러*/
class TalkHistoryTableViewController: UITableViewController {
    
    static var viewController : TalkHistoryTableViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            return storyboard.instantiateViewController(identifier: "talkHistory") as! TalkHistoryTableViewController
        } else {
            return storyboard.instantiateViewController(withIdentifier: "talkHistory") as! TalkHistoryTableViewController
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var introLabel:UILabel!
    @IBOutlet weak var emailButton:UIButton!
    
    var userId:String? = nil
    var userInfo:UserInfo? {
        guard let id = userId else {
            return nil
        }
        return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: id)
    }
    
    var filterText:String? = nil
    
    var talks:Results<TalkModel>? {
        if let id = userId {
            var result = try! Realm().objects(TalkModel.self)
                .filter("creatorId = %@ && bettingPoint == %@",id, 0)
            
            if let txt = filterText {
                result = result.filter("textForSearch CONTAINS[c] %@", txt)
            }
                
            return result.sorted(byKeyPath: "regTimeIntervalSince1970", ascending: false)
        }
        return nil
    }
    let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfo?.getTalkList(complete: { [weak self] (sucess) in
            self?.tableView.reloadData()
        })
        searchBar.placeholder = "text search".localized
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
        setData()
        title = "talk logs".localized
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem =
                UIBarButtonItem(title: "close".localized, style: .plain, target: self, action: #selector(self.onTouchupCloseBtn(_:)))
        }
    }
    
    @objc func onTouchupCloseBtn(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setData() {
        emailButton.setTitle(self.userId ?? "", for: .normal)
        guard let userInfo = self.userInfo else {
            nameLabel.text = ""
            introLabel.text = ""
            return
        }
        nameLabel.text = userInfo.name
        introLabel.text = userInfo.introduce
        
        profileImageView.kf.setImage(with: userInfo.profileImageURL, placeholder: #imageLiteral(resourceName: "profile"))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talks?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let talks = talks else {
            return UITableViewCell()
        }
        let data = talks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TalkHistoryTableViewCell
        cell.textView.text = data.textForSearch
        cell.dateLabel.text = data.regDt.simpleFormatStringValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let talks = talks else {
            return
        }
        let talk = talks[indexPath.row]
        let vc = TalkDetailTableViewController.viewController
        vc.documentId = talk.id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


class TalkHistoryTableViewCell : UITableViewCell {
    @IBOutlet weak var bubbleImageView:UIImageView!
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var dateLabel:UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleImageView.image = UIApplication.shared.isDarkMode ? #imageLiteral(resourceName: "bubble_dark") :#imageLiteral(resourceName: "bubble_light")
        dateLabel.textColor = .autoColor_weak_text_color
        textView.textColor = .autoColor_text_color
    }
}
