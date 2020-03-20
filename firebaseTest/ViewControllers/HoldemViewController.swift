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
protocol HoldemViewControllerDelegate : class {
    func didGameFinish(isBettingGame:Bool)
}

class HoldemViewController : UIViewController {
    weak var delegate:HoldemViewControllerDelegate? = nil
    
    @IBOutlet weak var jackPotBoxImageView: UIImageView!
    @IBOutlet weak var jackPotPointLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var myPointTitleLabel: UILabel!
    @IBOutlet weak var myPointLabel: UILabel!
    @IBOutlet weak var gamePlayButton: UIButton!
    static var viewController : HoldemViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "holdem") as! HoldemViewController
        } else {
            return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "holdem") as! HoldemViewController
        }
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        holdemView.insertCard()
        let closeBtnImage =
            #imageLiteral(resourceName: "closeBtn").af.imageAspectScaled(toFit: CGSize(width: 30, height: 30))//.withRenderingMode(.alwaysTemplate)
        if #available(iOS 13.0, *) {
            closeButton.setImage(closeBtnImage.withTintColor(.autoColor_text_color), for: .normal)
            closeButton.setImage(closeBtnImage.withTintColor(.autoColor_weak_text_color), for: .highlighted)
        } else {
            closeButton.setImage(closeBtnImage, for: .normal)
            closeButton.setImage(closeBtnImage, for: .highlighted)
        }
        JackPotManager.shared.getData { (sucess) in
            self.loadData()
        }
        setTitle()
        NotificationCenter.default.addObserver(forName: .jackpotChangeNotification, object: nil, queue: nil) { [weak self](notification) in
            self?.jackPotPointLabel.text = (notification.object as? Int)?.decimalForamtString
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        jackPotBoxImageView.image = UIApplication.shared.isDarkMode ? #imageLiteral(resourceName: "boxDark") : #imageLiteral(resourceName: "boxLight")
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
        loadData()
    }
    
    private func loadData() {
        myPointLabel.text = UserInfo.info?.point.decimalForamtString
        
        jackPotPointLabel.text = JackPotManager.shared.point.decimalForamtString
    }
    
    @IBAction func onTouchupCloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    @IBAction func onTouchupButton(_ sender: UIButton) {
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
                        if number > AdminOptions.shared.maxBettingPoint {
                            textFiled.text = AdminOptions.shared.maxBettingPoint.decimalForamtString
                        }
                        else if number > up {
                            textFiled.text = up.decimalForamtString
                        } else {
                            textFiled.text = number.decimalForamtString
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
            vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
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
            sender.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.onTouchupButton(sender)
                sender.isEnabled = true
            }
        case .preflop:
            holdemView.showCommunityCard(number: 3)
            gameState = .flop
        case .flop:
            gameMenuPopup(didBetting: { (point) in
                GameManager.shared.usePoint(point: point) { (sucess) in
                    if sucess {
                        self.loadData()
                        self.bettingPoint += point
                        self.holdemView.insertTurnRiver { (card) in
                            self.holdemView.communityCards.append(card)
                            self.holdemView.showCommunityCard(number: 4)
                            self.gameState = .turn
                            self.setTitle()
                        }
                    }
                }
            }) {
                //Fold Action
                let card = GameManager.shared.popCards(number: 4)
                self.holdemView.communityCards.append(card[1])
                self.holdemView.communityCards.append(card[3])
                self.holdemView.showCommunityCard(number: 5)
                self.holdemView.showDealerCard()
                self.gameState = .finish
                self.setTitle()
            }
        case .turn:
            gameMenuPopup(didBetting: { (point) in
                GameManager.shared.usePoint(point: point) { (sucess) in
                    if sucess {
                        self.loadData()
                        self.bettingPoint += point
                        self.holdemView.insertTurnRiver { (card) in
                            self.holdemView.communityCards.append(card)
                            self.holdemView.showCommunityCard(number: 5)
                            self.gameState = .river
                            sender.isEnabled = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                self.onTouchupButton(sender)
                                sender.isEnabled = true
                            }
                        }

                    }
                }
            }, didFold: nil)
        case .river:
            holdemView.showDealerCard()
            self.gameState = .finish
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                func showStatusView(statusChange:StatusChange) {
                    let vc = StatusViewController.viewController
                    vc.userId = UserInfo.info?.id
                    vc.statusChange = statusChange
                    self.present(vc, animated: true, completion: nil)
                }
                switch self.holdemView.gameResult {
                case .win:
                    JackPotManager.shared.addPoint(self.holdemView.dealarBetting) { [weak self](isSucess) in
                        let point = self?.holdemView.bettingPoint ?? 0  * 2
                        GameManager.shared.addPoint(point: point) { (sucess) in
                            self?.setTitle()
                            let set = self?.holdemView.myBestCardSet?.cardSet
                            
                            var isJackPod:Bool {
                                #if JACKPOTTEST
                                return true
                                #endif
                                if set?.cardValue == CardSet.CardValue.straightFlush {
                                    if (set?.cards.filter({ (card) -> Bool in
                                        return card.index == 13
                                    }).count == 1) {
                                        return true
                                    }
                                }
                                return false
                            }
                            
                            if isJackPod {
                                // 로티플이다!!
                                Toast.makeToast(message: "JackPot!!")
                                JackPotManager.shared.dropJackPot { (jackPod) in
                                    if let point = jackPod {
                                        GameManager.shared.addPoint(point: point) { (sucess) in
                                            showStatusView(statusChange:
                                                StatusChange(
                                                    addedExp: point,
                                                    pointChange: point - (self?.bettingPoint ?? 0)))

                                        }
                                    }
                                }
                            } else {
                                showStatusView(statusChange:
                                    StatusChange(
                                        addedExp: point,
                                        pointChange: point - (self?.bettingPoint ?? 0)))
                            }
                        }
                    }
                case .tie:
                    GameManager.shared.addPoint(point: self.holdemView.bettingPoint) { (sucess) in
                        self.setTitle()
                        showStatusView(statusChange:
                            StatusChange(addedExp: self.bettingPoint,
                                         pointChange: 0))

                    }
                case .lose:
                    JackPotManager.shared.addPoint(self.bettingPoint) { (isSucess) in
                        showStatusView(statusChange:
                            StatusChange(addedExp: self.bettingPoint,
                                         pointChange: -self.bettingPoint))
                    }
                default:
                    break
                }
            }
            break
        case .finish:
            // 승패 판정
            func newGame() {
                
                self.bettingPoint = 0
                self.holdemView.bettingPoint = 0
                self.holdemView.dealarBetting = 0
                self.holdemView.insertCard()
                self.gameState = .wait
                self.setTitle()
                self.loadData()
            }
            
            if bettingPoint > 0 {
                let gameCount = UserInfo.info?.todaysMyGameCount ?? 0
                if gameCount >= Consts.MAX_GAME_COUNT {
                    newGame()
                    return
                }
                let msg = String(format:"game posting alert desc %@ %@".localized, Consts.MAX_GAME_COUNT.decimalForamtString, (Consts.MAX_GAME_COUNT - gameCount).decimalForamtString)

                let vc = UIAlertController(title: "game posting alert title".localized,
                                           message: msg, preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "posting".localized, style: .default, handler: { (_) in
                    self.postTalk { (sucess) in
                        self.dismiss(animated: true) {
                            self.delegate?.didGameFinish(isBettingGame: true)
                        }
                    }
                }))
                vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: { (_) in
                    newGame()
                }))
                present(vc, animated: true, completion: nil)
                return
            } else {
                holdemView.insertCard()
                self.gameState = .wait
                setTitle()
                loadData()
                self.delegate?.didGameFinish(isBettingGame: false)
            }
        }
        setTitle()
        loadData()
    }
    
    func postTalk(complete:@escaping(_ sucess:Bool)->Void) {
        if holdemView.holdemResult == nil {
            complete(false)
            return
        }
        let model = TalkModel()
        let documentId = "holdem\(UUID().uuidString)\(UserInfo.info!.id)\(Date().timeIntervalSince1970)"
        let regTimeIntervalSince1970 = Date().timeIntervalSince1970
        
        model.loadData(id: documentId, text: "Holdem", creatorId: UserInfo.info!.id, regTimeIntervalSince1970: regTimeIntervalSince1970)
        model.bettingPoint = self.bettingPoint
        model.holdemResult = holdemView.holdemResult
        model.update { (sucess) in
            complete(sucess)
        }
    }
}

