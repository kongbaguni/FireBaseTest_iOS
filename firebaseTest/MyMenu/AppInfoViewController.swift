//
//  AppInfoViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/07/01.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
class AppInfoViewController: UITableViewController {
    /**
     앱 버전
     이용약관
     개인정보 처리방침
     오픈소스 라이센스
     */
    
    enum CellType: String, CaseIterable {
        case appVersion = "appVersion"
        case term = "term"
        case privacyPolicy = "privacyPolicy"
        case openSourceLicense = "openSourceLicense"
    }
    
    override func viewDidLoad() {
        title = "appInfo".localized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = CellType.allCases[indexPath.row]
        switch type {
        case .appVersion:
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.textLabel?.text = type.rawValue.localized
            cell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = type.rawValue.localized
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = CellType.allCases[indexPath.row]
        switch type {
        case .appVersion:
            break
        default:
            openWebView(type: type)
        }
    }
    
    private func openWebView(type:CellType) {
        var fileName = ""
        switch type {
        case .term:
            fileName = "term"
        case .privacyPolicy:
            fileName = "privacyPolicy"
        case .openSourceLicense:
            fileName = "openSourceLicense"
        default:
            break
        }
        if let url = Bundle.main.url(forResource: fileName, withExtension: "html") {
            let vc = WebViewController.viewController
            vc.url = url
            vc.title = type.rawValue.localized
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
