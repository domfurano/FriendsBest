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
    
    func getFacebookProfileImageView(facebookID: String, completionHandler: (profileImageView: UIImageView) -> Void) {
        NetworkQueue.instance.enqueue(NetworkTask(
            task: {
                [weak self] () -> Void in
                self?._getFacebookProfileImageView(facebookID, completionHandler: completionHandler)
            },
            description: "getFacebookProfileImageView()")
        )
    }
    
    private func _getFacebookProfileImageView(facebookID: String, completionHandler: (profileImageView: UIImageView) -> Void) {
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        let queryURL: NSURL? = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=large")
        
        guard let validQueryURL = queryURL else {
            NSLog("Error - Facebook API - getQueries() - Bad query URL")
            NetworkQueue.instance.dequeue()
            return
        }
        
        session.dataTaskWithURL(
            validQueryURL,
            completionHandler: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if let error = error {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - \(error)")
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                if !FBNetworkDAO.instance.responseHasExpectedStatusCode(response, expectedStatusCode: 200, funcName: "getFacebookProfileImageView") {
                    NetworkQueue.instance.tryAgain()
                    return
                }
                
                guard let validData = data else {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - Invalid data")
                    NetworkQueue.instance.dequeue()
                    return
                }
                
                let profileImage: UIImage? = UIImage(data: validData)
                
                guard let validProfileImage: UIImage = profileImage else {
                    NSLog("Error - Facebook API - getFacebookProfileImageView() - Nil image")
                    NetworkQueue.instance.dequeue()
                    return
                }
                
                let profileImageView: UIImageView = UIImageView(image: validProfileImage)
                
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    {
                        () -> Void in
                        completionHandler(profileImageView: profileImageView)
                        NetworkQueue.instance.dequeue()
                    }
                )
        }).resume()
    }
    
    func getFacebookUserID() {
        
//        [FBRequestConnection
//            startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//            if (!error) {
//            NSString *facebookId = [result objectForKey:@"id"];
//            }
//            }];
    }
    
}


































