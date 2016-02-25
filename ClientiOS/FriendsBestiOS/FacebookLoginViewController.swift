//
//  FacebookLoginViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/1/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FacebookLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let loginButton: FBSDKLoginButton = FBSDKLoginButton()
    
//    NetworkDAO.instance.authenticatedWithFriendsBestServerDelegate = {
//    
//    }
    
    override func loadView() {
        view = FacebookLoginView(loginButton: loginButton)
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBarHidden = true
        navigationController?.toolbarHidden = true
        
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.delegate = self
        
        FBNetworkDAO.instance.authenticatedWithFriendsBestServerDelegate = {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        // TODO: Deal with declined permissons

        if error == nil && FBSDKAccessToken.currentAccessToken() != nil {
            // Authenticate with FriendsBest
            FBNetworkDAO.instance.postFacebookTokenAndAuthenticate()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //
    }
    
}
















