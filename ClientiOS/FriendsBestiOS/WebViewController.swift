//
//  WebViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/10/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import WebKit


class WebViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    var progressView: UIProgressView!
    
    var urlTextField: UITextField!
    
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    
    var newRecommendation: NewRecommendation!
    var webView: WKWebView {
        get {
            return view as! WKWebView
        }
    }
    
    convenience init(newRecommendation: NewRecommendation) {
        self.init()
        self.newRecommendation = newRecommendation
    }
    
    deinit {
        NSLog("deinit() - WebViewController")
        webView.removeObserver(self, forKeyPath: "loading")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func loadView() {
        view = WKWebView()
    }
    
    override func viewDidLoad() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        if newRecommendation.detail != nil {
            if let URL: NSURL = NSURL(string: newRecommendation.detail!) {
                let request: NSURLRequest = NSURLRequest(URL: URL)
                webView.loadRequest(request)
            }
        }
        
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
        progressView.tintColor = CommonUI.fbGreen
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.hidden = true
        
        view.insertSubview(progressView, aboveSubview: webView)
        webView.addConstraint(
            NSLayoutConstraint(
                item: progressView,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: webView,
                attribute: .Width,
                multiplier: 1.0,
                constant: 0.0))
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        
        let leftBBitem: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.nbTimes,
            style: .Plain,
            target: self,
            action: #selector(WebViewController.dismiss)
        )
        leftBBitem.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = leftBBitem
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusSquareIconWithSize(CommonUI.ICON_FLOAT)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CommonUI.ICON_SIZE)
        let rightBB: UIBarButtonItem = UIBarButtonItem(
            image: fa_plus_square_image,
            style: .Plain,
            target: self,
            action: #selector(WebViewController.createNewRecommendationButtonPressed)
        )
        rightBB.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBB
        
        /* url bar */
        urlTextField = UITextField(frame: CGRectMake(0, 0, 300, 30))
        urlTextField.layer.cornerRadius = 4.0
        
        
        urlTextField.delegate = self
        urlTextField.keyboardType = .WebSearch
        urlTextField.returnKeyType = .Go
        urlTextField.autocapitalizationType = .None
        urlTextField.autocorrectionType = .No
        urlTextField.leftViewMode = .Always
        
        urlTextField.backgroundColor = UIColor.whiteColor()
        let globeView: UIImageView = CommonUI.globeView
        globeView.alpha = 0.5
        urlTextField.leftView = globeView
        urlTextField.placeholder = "Search or enter a website"
        urlTextField.clearButtonMode = .WhileEditing
        
        navigationItem.titleView = urlTextField
        
        /* Toolbar */
        let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        backButton = UIBarButtonItem(image: CommonUI.wvBackChevron, style: .Plain, target: self, action: #selector(WebViewController.back))
        backButton.tintColor = CommonUI.fbGreen
        forwardButton = UIBarButtonItem(image: CommonUI.wvForwardChevron, style: .Plain, target: self, action: #selector(WebViewController.forward))
        forwardButton.tintColor = CommonUI.fbGreen
        reloadButton = UIBarButtonItem(image: CommonUI.wvRefresh, style: .Plain, target: self, action: #selector(WebViewController.reload))
        reloadButton.tintColor = CommonUI.fbGreen
        
        setToolbarItems([backButton, fixedSpace, forwardButton, flexibleSpace, reloadButton], animated: false)
        
        backButton.enabled = false
        forwardButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        navigationController?.navigationBar.barTintColor = CommonUI.fbGreen
    }
    
    override func viewWillDisappear(animated: Bool) {
        urlTextField.resignFirstResponder()
    }
    
    func createNewRecommendationButtonPressed() {
        if let urlString = webView.URL?.absoluteString {
            NSLog(urlString)
            newRecommendation.type = .url
            newRecommendation.detail = urlString
            navigationController?.pushViewController(NewRecommendationFormViewController(newRecommendation: newRecommendation, type: .NEW), animated: true)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "loading") {
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
        }
        
        if (keyPath == "estimatedProgress") {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
        urlTextField.text = webView.URL?.host
    }
    
    func dismiss() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let inputText = textField.text {
            
            // I'm gonna hack this because I could develop it to death, but lets assume the user is friendly.
            
            let components: [String: String?] = urlComponentsDict(inputText)
            let scheme: String? = components["scheme"]!
            let host_a: String? = components["host_a"]!
            let host_b: String? = components["host_b"]!
            
            if host_a == nil {
                searchGoogle(inputText)
                textField.resignFirstResponder()
                return false
            }
            
            let urlComponents: NSURLComponents = NSURLComponents()
            
            urlComponents.scheme = scheme == nil ? "http" : scheme!
            urlComponents.host = host_a! + (host_b == nil ? "" : "." + host_b!)
            
            print(urlComponents)
            if let url = urlComponents.URL {
                webView.loadRequest(NSURLRequest(URL: url))
            } else {
                searchGoogle(inputText)
            }
        }
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = webView.URL?.absoluteString
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.text = webView.URL?.host
    }
    
    private func searchGoogle(searchString: String) {
        let googleSearchURL: NSURL = NSURL(string: "https://www.google.com/search?q=\(searchString.stringByReplacingOccurrencesOfString(" ", withString: "+"))")!
        webView.loadRequest(NSURLRequest(URL: googleSearchURL))
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
    }
    
    /* Toolbar */
    
    func back(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    func forward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    func reload(sender: UIBarButtonItem) {
        if let url = webView.URL {
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    func urlComponentsDict(input: String!) -> [String: String?] {
        var components: [String: String?] = ["scheme": nil, "host_a": nil, "host_b": nil]
        do {
            let nsStringInput: NSString = input.lowercaseString as NSString
            let urlRegex: String = "(https?){0,1}[:\\/]*([\\d\\w\\.-]+)\\.([a-z]+)"
            let regex: NSRegularExpression = try NSRegularExpression(pattern: urlRegex, options: [])
            let matches = regex.matchesInString(input, options: [], range: NSMakeRange(0, nsStringInput.length))
            for match: NSTextCheckingResult in matches {
                let match_1: NSRange = match.rangeAtIndex(1)
                let match_2: NSRange = match.rangeAtIndex(2)
                let match_3: NSRange = match.rangeAtIndex(3)
                
                if match_1.length != 0 {
                    components["scheme"] = nsStringInput.substringWithRange(match_1)
                }
                
                if match_2.length != 0 {
                    components["host_a"] = nsStringInput.substringWithRange(match_2)
                }
                
                if match_3.length != 0 {
                    components["host_b"] = nsStringInput.substringWithRange(match_3)
                }
            }
        } catch let error as NSError {
            fatalError("invalid regex: \(error.localizedDescription)")
        }
        return components
    }
    
}


















































 