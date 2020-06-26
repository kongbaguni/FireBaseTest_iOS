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
import Lightbox
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
    
    var reviews:Results<ReviewModel>? {
        if let id = userId {
            var result = try! Realm().objects(ReviewModel.self).filter("creatorId = %@", id)
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return talks?.count ?? 0
        case 2:
            return reviews?.count ?? 0
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
            if data.isDeletedByAdmin {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TalkHistoryTableViewCell
                cell.bubbleImageView.alpha = 0.5
                cell.textView.text = "deleted by Admin".localized
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
        case 2:
            guard let review = reviews?[indexPath.row] else {
                return UITableViewCell()
            }
            if review.isDeletedByAdmin {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TalkHistoryTableViewCell
                cell.bubbleImageView.alpha = 0.5
                cell.textView.text = "deleted by Admin".localized
                cell.textView.isSelectable = false
                cell.textView.alpha = 0.5
                cell.dateLabel.text = review.regDt.simpleFormatStringValue
                return cell
            }
            var starPoint = ""
            if review.starPoint > 0 && review.starPoint <= Consts.stars.count {
                starPoint = Consts.stars[review.starPoint-1]
            }
            let text = """
            \(review.name)
            \(review.comment)
            \(starPoint)
            """
            
            if let url = review.photoUrlList.first {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! TalkHistoryImageTableViewCell
                cell.textView.text = text
                cell.attachImageView?.kf.setImage(with: url,placeholder: UIImage.placeHolder_image)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TalkHistoryTableViewCell
            cell.textView.text = text
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let url = userInfo?.profileLargeImageURL {
                let vc = LightboxController(images: [LightboxImage(imageURL: url)], startIndex: 0)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)
            }
        case 1:
            guard let talk = talks?[indexPath.row] else {
                return
            }
            if talk.isDeletedByAdmin {
                alert(title: "alert".localized, message: "deleted by admin msg".localized, didConfirm: {[weak tableView] _ in
                    tableView?.deselectRow(at: indexPath, animated: true)
                })
                return
            }
            if talk.isDeleted {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let vc = TalkDetailTableViewController.viewController
            vc.documentId = talk.id
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            guard let review = reviews?[indexPath.row] else {
                return
            }
            if review.isDeletedByAdmin {
                alert(title: "alert".localized, message: "deleted by admin msg".localized, didConfirm: { [weak tableView] _ in
                    tableView?.deselectRow(at: indexPath, animated: true)
                })
                return
            }
            let vc = ReviewDetailViewController.viewController
            vc.reviewId = review.id
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
        case 2:
            return "review".localized
        default:
            return nil
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 1:
            if (talks?.count ?? 0) == 0 {
                let label = UILabel()
                label.text = "talks empty msg".localized
                label.textAlignment = .center
                return label
            }
            return nil
        case 2:
            if (reviews?.count ?? 0) == 0 {
                let label = UILabel()
                label.text = "reviews empty msg".localized
                label.textAlignment = .center
                return label
            }
            return nil
        default:
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            if (talks?.count ?? 0) == 0 {
                return 50
            }
            return CGFloat.leastNormalMagnitude
        case 2:
            if (reviews?.count ?? 0) == 0 {
                return 50
            }
            return CGFloat.leastNormalMagnitude
        default:
            return CGFloat.leastNormalMagnitude
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
