//
//  WebViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/10/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView {
        get {
            return view as! WKWebView
        }
    }

    override func loadView() {
        view = WKWebView(frame: UIScreen.mainScreen().bounds)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func viewDidLoad() {
        navigationController?.toolbarHidden = true

        
        let url = NSURL(string: "https://www.google.com/")!
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
}
