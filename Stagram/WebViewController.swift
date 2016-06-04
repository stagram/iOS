//
//  WebViewController.swift
//  Stagram
//
//  Created by Dongri Jin on 4/6/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation

import OAuthSwift

import UIKit
typealias WebView = UIWebView // WKWebView

class WebViewController: OAuthWebViewController, UIWebViewDelegate {
    
    var targetURL : NSURL = NSURL()
    let webView : WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = UIScreen.mainScreen().bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
    }
    
    override func handle(url: NSURL) {
        targetURL = url
        super.handle(url)
        
        loadAddressURL()
    }
    
    func loadAddressURL() {
        let req = NSURLRequest(URL: targetURL)
        self.webView.loadRequest(req)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.URL where (url.scheme == "stagram"){
            self.dismissWebViewController()
        }
        return true
    }
}

