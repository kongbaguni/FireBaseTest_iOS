//
//  WebViewController.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/20.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {    
    static var viewController : WebViewController {
        let s = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            return s.instantiateViewController(identifier: "webview") as! WebViewController
        } else {
            return s.instantiateViewController(withIdentifier: "webview") as! WebViewController
        }
    }
    
    var url:URL? = nil
    
    @IBOutlet weak var webview:WKWebView!
    
    let loading = Loading()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        if let url = self.url {
            webview.load(URLRequest(url: url))
            webview.alpha = 0.5
            loading.show(viewController: self)
        }
    }
    
    @objc func onTouchupCloseBtn(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension WebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading.hide()
        webView.alpha = 1
    }
}
