//
//  ProfileViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/11/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class ProfileViewController: UIViewController {
    
    let facebookProfilePictureView: FBSDKProfilePictureView = FBSDKProfilePictureView(frame: CGRectMake(0, 0, 256, 256))
    var pictureView: UIView?
    
    override func loadView() {
        self.view = ProfileView()
    }
    
    override func viewDidLoad() {x
        pictureView = UIView(frame: self.view.frame)
        pictureView!.translatesAutoresizingMaskIntoConstraints = false
        pictureView!.addSubview(facebookProfilePictureView)
        

        
        self.view.addSubview(pictureView!)
        
        facebookProfilePictureView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints()
        

    }
    
    private func addConstraints() {
        self.view.addConstraint(
            NSLayoutConstraint(
                item: pictureView!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 0.4,
                constant: 0.0))
        
        self.view.addConstraint(
            NSLayoutConstraint(
                item: pictureView!,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.7,
                constant: 0.0))
        
        self.view.addConstraint(
            NSLayoutConstraint(
                item: pictureView!,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        //        self.addConstraint(
        //            NSLayoutConstraint(
        //                item: facebookProfileImageView!,
        //                attribute: NSLayoutAttribute.CenterX,
        //                relatedBy: NSLayoutRelation.Equal,
        //                toItem: self,
        //                attribute: NSLayoutAttribute.CenterX,
        //                multiplier: 1.0,
        //                constant: 0.0))
        //
        //        self.addConstraint(
        //            NSLayoutConstraint(
        //                item: facebookProfileImageView!,
        //                attribute: NSLayoutAttribute.CenterY,
        //                relatedBy: NSLayoutRelation.Equal,
        //                toItem: self,
        //                attribute: NSLayoutAttribute.CenterY,
        //                multiplier: 1.5,
        //                constant: 0.0))
    }
    
}
