//
//  HoldemViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class HoldemViewController : UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var myPointTitleLabel: UILabel!
    @IBOutlet weak var myPointLabel: UILabel!
    @IBOutlet weak var myBettingTitleLabel: UILabel!
    @IBOutlet weak var myBettingLabel: UILabel!
    @IBOutlet weak var gamePlayButton: UIButton!
    static var viewController : HoldemViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "holdem") as! HoldemViewController
    }
    @IBOutlet weak var holdemView:HoldemView!
    let disposebag = DisposeBag()
    
    enum GameState:String {
        /** 대기중*/
        case wait = "Holdem"
        /** 각 플레이어가 2장씩 카드 받음*/
        case preflop = "preflop"
        /** 바닥에 커뮤니티 카드 3장 오픈*/
        case flop = "flop"
        /** 4번째 커뮤니티 카드 오픈*/
        case turn = "turn"
        /** 5번째 커뮤니티 카드 오픈*/
        case river = "river"
        /** 딜러카드 오픈*/
        case finish = "finish"
    }
    
    var gameState:GameState = .wait
    var bettingPoint:Int = 0 {
        didSet {
            holdemView.bettingPoint = bettingPoint
            myBettingLabel.text = bettingPoint.decimalForamtString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        holdemView.insertCard()
        let closeBtnImage =
            #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))//.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(closeBtnImage.withTintColor(.autoColor_text_color), for: .normal)
        closeButton.setImage(closeBtnImage.withTintColor(.autoColor_weak_text_color), for: .highlighted)
        
        loadData()
        setTitle()
    }
    
    
    private func setTitle() {
        titleLabel.text = gameState.rawValue.localized
        switch gameState {
        case .wait:
            gamePlayButton.setTitle("playGame".localized, for: .normal)
        case .preflop:
            gamePlayButton.setTitle("continue".localized, for: .normal)
        case .flop,.turn:
            closeButton.isEnabled = false
            gamePlayButton.setTitle("check".localized, for: .normal)
        case .river:
            closeButton.isEnabled = false
            gamePlayButton.setTitle("continue".localized, for: .normal)
        case .finish:
            closeButton.isEnabled = true
            if self.bettingPoint > 0 {
                gamePlayButton.setTitle("game over".localized, for: .normal)
            } else {
                gamePlayButton.setTitle("playGame".localized, for: .normal)
            }

        }
        myPointTitleLabel.text = "MyPoints".localized
        myBettingTitleLabel.text = "betting".localized
        if let result = holdemView.gameResult {
            switch result {
            case .win:
                titleLabel.text = "win".localized
            case .tie:
                titleLabel.text = "tie".localized
            case .lose:
                titleLabel.text = "lose".localized
            }
        }
    }
    private func loadData() {
        myPointLabel.text = UserInfo.info?.point.decimalForamtString
        myBettingLabel.text = bettingPoint.decimalForamtString
    }
    
    @IBAction func onTouchupCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    @IBAction func onTouchupButton(_ sender: Any) {
        func bettingPointAlert(didBetting:@escaping(_ bettingPoint:Int)->Void) {
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
                didBetting(betting)
            }))
            vc.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(vc, animated: true, completion: nil)
        }
        
        func gameMenuPopup(
            didBetting:@escaping(_ bettingPoint:Int)->Void
            ,didFold:(()->Void)?) {
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "betting".localized, style: .default, handler: { (action) in
                bettingPointAlert { (bettingPoint) in
                    didBetting(bettingPoint)
                }
            }))
            if let foldAction = didFold {
                ac.addAction(UIAlertAction(title: "fold".localized, style: .default, handler: { (action) in
                    foldAction()
                }))
            }
            ac.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        
        switch gameState {
        case .wait:
            holdemView.showMyCard()
            gameState = .preflop
        case .preflop:
            holdemView.showCommunityCard(number: 3)
            gameState = .flop
        case .flop:
            gameMenuPopup(didBetting: { (point) in
                self.bettingPoint += point
                self.holdemView.showCommunityCard(number: 4)
                self.gameState = .turn
                self.setTitle()
            }) {
                self.holdemView.showCommunityCard(number: 5)
                self.holdemView.showDealerCard()
                self.gameState = .finish
                self.setTitle()
            }
        case .turn:
            gameMenuPopup(didBetting: { (point) in
                self.bettingPoint += point
                self.holdemView.showCommunityCard(number: 5)
                self.gameState = .river
            }, didFold: nil)
        case .river:
            holdemView.showDealerCard()
            self.gameState = .finish
            break
        case .finish:
            // 승패 판정
            if bettingPoint > 0 {
                dismiss(animated: true, completion: nil)
                break
            } else {
                holdemView.insertCard()
                self.gameState = .wait
                setTitle()
            }
        }
        setTitle()
    }
}

