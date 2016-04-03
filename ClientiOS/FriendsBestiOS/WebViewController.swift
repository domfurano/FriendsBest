//
//  WebViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/10/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import WebKit

//

class WebViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    var currentURLString: String = "https://www.google.com/"
    
    var progressView: UIProgressView!
    
    var urlTextField: UITextField!
    
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    
    var webView: WKWebView {
        get {
            return view as! WKWebView
        }
    }
    
    override func loadView() {
        view = WKWebView()
    }
    
    override func viewDidLoad() {
        //        navigationController?.navigationBar.translucent = false
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.loadRequest(NSURLRequest(URL: NSURL(string: currentURLString)!))
        
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        
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
            action: #selector(NewRecommendationViewController.createNewRecommendationButtonPressed)
        )
        rightBB.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBB
        
        /* url bar */
        urlTextField = UITextField(frame: CGRectMake(0, 0, 300, 30))
        urlTextField.layer.cornerRadius = 4.0
        
        
        urlTextField.delegate = self
        urlTextField.keyboardType = .URL
        urlTextField.returnKeyType = .Go
        urlTextField.autocapitalizationType = .None
        urlTextField.autocorrectionType = .No
        urlTextField.leftViewMode = .Always
        
        urlTextField.backgroundColor = UIColor.whiteColor()
        let globeView: UIImageView = CommonUI.globeView
        globeView.tintColor = UIColor.darkGrayColor()
        urlTextField.leftView = globeView
        urlTextField.placeholder = "Enter website"
        urlTextField.clearButtonMode = .WhileEditing
        
        navigationItem.titleView = urlTextField
        
        /* Toolbar */
        let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        backButton = UIBarButtonItem(barButtonSystemItem: .Rewind, target: self, action: #selector(WebViewController.back))
        forwardButton = UIBarButtonItem(barButtonSystemItem: .FastForward, target: self, action: #selector(WebViewController.forward))
        reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(WebViewController.reload))
        
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
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
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
    }
    
    func dismiss() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let inputText = textField.text {
            currentURLString = inputText
            checkURLReachability(NSURL(string: inputText)!)
        }
        
        return false
    }
    
    private func checkURLReachability(url: NSURL) {
        let session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "HEAD"
        
        session.dataTaskWithRequest(request, completionHandler: {
            [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if data != nil {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self?.webView.loadRequest(NSURLRequest(URL: NSURL(string: self!.currentURLString)!))
                })
            } else {
                let googleSearchURL: NSURL = NSURL(string: "https://www.google.com/search?q=\(self!.currentURLString.stringByReplacingOccurrencesOfString(" ", withString: "+"))")!
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self?.webView.loadRequest(NSURLRequest(URL: googleSearchURL))
                })
            }
            }).resume()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /* Toolbar */
    
    func back(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    func forward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    func reload(sender: UIBarButtonItem) {
        webView.loadRequest(NSURLRequest(URL: webView.URL!))
    }
    
}


















































 