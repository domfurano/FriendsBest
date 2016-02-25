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
    
    var profileImageView: UIImageView? = nil
    
//    let facebookProfilePictureView: FBSDKProfilePictureView = FBSDKProfilePictureView(frame: CGRectMake(0, 0, 256, 256))
//    var pictureView: UIView?
    
    override func loadView() {
        self.view = ProfileView()
    }
    
    override func viewDidLoad() {
//        pictureView = UIView(frame: self.view.frame)
//        pictureView!.translatesAutoresizingMaskIntoConstraints = false
//        pictureView!.addSubview(facebookProfilePictureView)
        
//        pictureView!.layer.masksToBounds = true
//        pictureView!.layer.cornerRadius = pictureView!.bounds.width / 2
        

        
//        self.view.addSubview(pictureView!)
        
        FacebookNetworkDAO.instance.getFacebookProfileImageView(User.instance.facebookID!) {
                [weak self] (profileImageView) -> Void in
                self?.profileImageView = profileImageView
//                self?.profileImageView?.translatesAutoresizingMaskIntoConstraints = false
                self?.view.addSubview((self?.profileImageView)!)
//                self?.addConstraints()
//                self?.view.setNeedsDisplay()
//                self?.profileImageView?.setNeedsDisplay()
        }
    }
    
    private func addConstraints() {
        self.view.addConstraint(
            NSLayoutConstraint(
                item: profileImageView!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
//        self.view.addConstraint(
//            NSLayoutConstraint(
//                item: profileImageView!,
//                attribute: NSLayoutAttribute.Width,
//                relatedBy: NSLayoutRelation.Equal,
//                toItem: self.view,
//                attribute: NSLayoutAttribute.Width,
//                multiplier: 0.7,
//                constant: 0.0))
        
        self.view.addConstraint(
            NSLayoutConstraint(
                item: profileImageView!,
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
