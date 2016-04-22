//
//  FacebookNetworkDAO.swift
//  FriendsBest
//
//  Created by Dominic Furano on 2/25/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import FBSDKCoreKit


class FacebookNetworkDAO {
    
    static var instance = FacebookNetworkDAO()
    
    private init() { }
    
    func getFacebookData(callback: ((successful: Bool) -> Void)?) {
        let request: FBSDKGraphRequest = FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": "email,name"]
        )
        
        request.startWithCompletionHandler {
            (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) in
            if(error == nil)
            {
                let dict: NSDictionary = result as! NSDictionary
                User.instance.name = dict["name"] as? String
                callback?(successful: true)
            }
            else
            {
                NSLog("error \(error)")
                callback?(successful: false)
            }
        }
    }
    
}


































