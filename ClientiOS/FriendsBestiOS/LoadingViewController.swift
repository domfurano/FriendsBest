//
//  LoadingViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/22/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class LoadingView: UIView {
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)
        
        CommonUI.drawGradientForContext(
            [
                CommonUI.topGradientColor,
                CommonUI.bottomGradientColor
            ],
            frame: self.bounds,
            context: context
        )
    }
}

class LoadingViewController: UIViewController {
    
    override func loadView() {
        view = LoadingView()
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
    }
    
    override func viewDidAppear(animated: Bool) {
        /* Facebook */ // TODO: Add this to a "loading" viewcontroller
        if FBSDKAccessToken.currentAccessToken() == nil {
            navigationController?.pushViewController(FacebookLoginViewController(), animated: false)
        } else {
            User.instance.facebookID = FBSDKAccessToken.currentAccessToken().userID
            FacebookNetworkDAO.instance.getFacebookData()            
            
            FBNetworkDAO.instance.getPrompts()
            
            CommonUI.instance
            UpdateBullshitter.instance
            
            while CommonUI.largeProfilePicture == nil { }
            while CommonUI.smallProfilePicture == nil { }
            
            navigationController?.pushViewController(MainScreenViewController(), animated: false)
        }
    }
    
}
