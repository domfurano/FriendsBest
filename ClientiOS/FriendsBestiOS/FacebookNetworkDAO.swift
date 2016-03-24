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
    
    
    enum FacbookImageSize: String {
        case small = "small"
        case normal = "normal"
        case album = "album"
        case large = "large"
        case square = "square"
    }
    
    func getFacebookProfileImageView(facebookID: String, size: FacbookImageSize, completionHandler: (profileImageView: UIImageView) -> Void) {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryURL: NSURL? = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=\(size.rawValue)")
        
        guard let validQueryURL = queryURL else {
            NSLog("Error - Facebook API - getQueries() - Bad query URL")
            return
        }
        
        session.dataTaskWithURL(
            validQueryURL,
            completionHandler: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let error = error {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - \(error)")
                    return
                }
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getFacebookProfileImageView") {
                    return
                }
                
                guard let validData = data else {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - Invalid data")
                    return
                }
                
                let profileImage: UIImage? = UIImage(data: validData)
                
                guard let validProfileImage: UIImage = profileImage else {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - Nil image")
                    return
                }
                
                let profileImageView: UIImageView = UIImageView(image: validProfileImage)
                completionHandler(profileImageView: profileImageView)
        }).resume()
    }
    
    func getFacebookProfileImage(facebookID: String, size: FacbookImageSize, completionHandler: (profileImage: UIImage) -> Void) {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryURL: NSURL? = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=\(size.rawValue)")
        
        guard let validQueryURL = queryURL else {
            NSLog("Error - Facebook API - getQueries() - Bad query URL")
            return
        }
        
        session.dataTaskWithURL(
            validQueryURL,
            completionHandler: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let error = error {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - \(error)")
                    return
                }
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getFacebookProfileImageView") {
                    return
                }
                
                guard let validData = data else {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - Invalid data")
                    return
                }
                
                let profileImage: UIImage? = UIImage(data: validData)
                
                guard let validProfileImage: UIImage = profileImage else {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - Nil image")
                    return
                }
                
                completionHandler(profileImage: validProfileImage)
        }).resume()
    }
    
    func getFacebookData() {
        let request: FBSDKGraphRequest = FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": "email,name"]
        )
        
//        dispatch_async(dispatch_queue_create("facebookQueue", DISPATCH_QUEUE_SERIAL)) {
            request.startWithCompletionHandler {
                (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) in
                if(error == nil)
                {
                    let dict: NSDictionary = result as! NSDictionary
                    User.instance.name = dict["name"] as? String
                }
                else
                {
                    NSLog("error \(error)")
                }
            }
//        }
    }
    
}


































