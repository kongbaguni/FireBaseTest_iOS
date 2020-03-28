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
                .filter("creatorId = %@ && gameResultBase64encodingSting = %@",id, "")
            
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
        onRefreshControll(UIRefreshControl())
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
        title = "talk logs".localized
        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem =
                UIBarButtonItem(title: "close".localized, style: .plain, target: self, action: #selector(self.onTouchupCloseBtn(_:)))
        }
        refreshControl?.addTarget(self, action: #selector(self.onRefreshControll(_:)), for: .valueChanged)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    let loading = Loading()
    @objc func onRefreshControll(_ sender:UIRefreshControl) {
        if sender != self.refreshControl {
            loading.show(viewController: self)
        }
        userInfo?.getTalkList(complete: { [weak self] (sucess) in
            sender.endRefreshing()
            self?.loading.hide()
            self?.tableView.reloadData()
        })
    }
    
    @objc func onTouchupCloseBtn(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
      
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            let count = talks?.count ?? 0
            return count == 0 ? 1 : count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profile", for: indexPath) as! TalHistoryUserProfileTableViewCell
            cell.userId = self.userId
            cell.setData()
            return cell
        case 1:
            guard let talks = talks else {
                return UITableViewCell()
            }
            if talks.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
                cell.textLabel?.text = "talk logs is empty".localized
                return cell
            }
            let data = talks[indexPath.row]
            if data.isDeleted {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TalkHistoryTableViewCell
                cell.bubbleImageView.alpha = 0.5
                cell.textView.text = "deleted talk".localized
                cell.textView.isSelectable = false
                cell.textView.alpha = 0.5
                cell.dateLabel.text = data.regDt.simpleFormatStringValue
                return cell
            }
            if let url = data.imageURL {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! TalkHistoryImageTableViewCell
                cell.textView.text = data.textForSearch
                cell.dateLabel.text = data.regDt.simpleFormatStringValue
                cell.attachImageView.kf.setImage(with: url,placeholder: #imageLiteral(resourceName: "placeholder") )
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TalkHistoryTableViewCell
                cell.textView.text = data.textForSearch
                cell.dateLabel.text = data.regDt.simpleFormatStringValue
                return cell
            }
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            guard let talks = talks else {
                return
            }
            let talk = talks[indexPath.row]
            if talk.isDeleted {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let vc = TalkDetailTableViewController.viewController
            vc.documentId = talk.id
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "profile".localized
        case 1:
            return "talk logs".localized
        default:
            return nil
        }
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
        bubbleImageView.image = .bubble
        dateLabel.textColor = .autoColor_weak_text_color
        textView.textColor = .autoColor_text_color
    }
}

class TalkHistoryImageTableViewCell : TalkHistoryTableViewCell {
    @IBOutlet weak var attachImageView:UIImageView!
}


class TalHistoryUserProfileTableViewCell : UITableViewCell {
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var introLabel:UILabel!
    @IBOutlet weak var emailButton:UIButton!
    
    var userId:String? = nil
    
    var user:UserInfo? {
        if let id = userId {
            return try! Realm().object(ofType: UserInfo.self, forPrimaryKey: id)
        }
        return nil
    }
    let disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setData()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        emailButton.rx.tap.bind {[weak self] (_) in
            self?.user?.email.sendMail()
        }.disposed(by: disposeBag)
    }
    
    func setData() {
        profileImageView.kf.setImage(with: user?.profileImageURL, placeholder: UIImage.placeHolder_profile)
        nameLabel.text = user?.name
        introLabel.text = user?.introduce
        emailButton.setTitle(user?.email, for: .normal)
    }

}
