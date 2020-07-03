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
    
    var url:URL? = nil {
        didSet {
            navigationItem.rightBarButtonItem = nil
            if let url = url {
                if url.isFileURL == false {
                    if UIApplication.shared.canOpenURL(url) {
                        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.openAsSafari(_:)))
                    }
                }
            }
        }
    }
    
    @objc func openAsSafari(_ sender:UIBarButtonItem) {
        if let url = self.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
         }
    }
    
    @IBOutlet weak var webview:WKWebView!
    
    let loading = Loading()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.navigationDelegate = self
        webview.alpha = 0
        if let url = self.url {            
            webview.load(URLRequest(url: url))
            loading.show(viewController: self)
        }
        makeModalCloseBarButtonItmIfNeed(selector:#selector(self.onTouchupCloseBtn(_:)))
    }
    
    @objc func onTouchupCloseBtn(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func changeDisplyStyleWebview() {
        if url?.isFileURL == true {
            webview?.evaluateJavaScript("changeMode('\(UIApplication.shared.isDarkMode ? "dark" : "light")')", completionHandler: { (_, error) in
                
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        changeDisplyStyleWebview()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        guard let url = request.url else {
            decisionHandler(.allow)
            return
        }
        print(url.absoluteString)
        switch url.absoluteString.components(separatedBy: ":").first?.lowercased() {
        case "http", "https", "file":
            let urla = webview.url?.absoluteString.components(separatedBy: "#").first
            let urlb = request.url?.absoluteString.components(separatedBy: "#").first
            if self.webview.url != nil && urla != urlb {
                let vc = WebViewController.viewController
                vc.url = url
                vc.title = url.absoluteString
                navigationController?.pushViewController(vc, animated: true)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        default:
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        }
        
    }
}

extension WebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading.hide()
        changeDisplyStyleWebview()
        UIView.animate(withDuration: 0.25) {
            webView.alpha = 1
        }
        webview.evaluateJavaScript("document.getElementsByTagName('title')[0].innerText") { [weak self](result, error) -> Void in
            if let txt = result as? String {
                self?.title = txt
            }
        }
    }
}
