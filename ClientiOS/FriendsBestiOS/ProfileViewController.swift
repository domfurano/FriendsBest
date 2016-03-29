//
//  ProfileViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/11/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ProfileView: UIView {
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

class ProfileViewController: UIViewController {
    
    let largeProfilePicture: UIImageView = CommonUI.largeProfilePicture!
    let smallProfilePicture: UIImageView = CommonUI.smallProfilePicture!
    
    var nameLabel: UILabel = UILabel()
    var recommendationsButton: UIButton = UIButton()
    var friendsButton: UIButton = UIButton()
    var logoutButton: UIButton = UIButton()
    var removeAccountButton: UIButton = UIButton()
    
    override func loadView() {
        self.view = ProfileView()
    }
    
    override func viewDidLoad() {
        largeProfilePicture.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(largeProfilePicture)
        largeProfilePicture.layer.cornerRadius = largeProfilePicture.frame.size.width / 2.0
        largeProfilePicture.clipsToBounds = true
//        largeProfilePicture.layer.masksToBounds = false
//        largeProfilePicture.layer.shadowOpacity = 1.0
//        largeProfilePicture.layer.shadowOffset.height = 12.0
//        largeProfilePicture.layer.shadowColor = UIColor.redColor().CGColor
        
        nameLabel.text = User.instance.name!
        recommendationsButton.setTitle("Recommendations", forState: .Normal)
        friendsButton.setTitle("Friends using FriendsBest", forState: .Normal)
        logoutButton.setTitle("Logout", forState: .Normal)
        removeAccountButton.setTitle("Remove Account", forState: .Normal)
        
        recommendationsButton.contentHorizontalAlignment = .Left
        friendsButton.contentHorizontalAlignment = .Left
        
        recommendationsButton.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 0)
        friendsButton.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 0)
        logoutButton.contentEdgeInsets = UIEdgeInsetsMake(8, 0, 8, 0)
        removeAccountButton.contentEdgeInsets = UIEdgeInsetsMake(8, 0, 8, 0)
        
        nameLabel.font = UIFont(name: "Proxima Nova Cond", size: 28.0)!
        recommendationsButton.titleLabel?.font = UIFont(name: "Proxima Nova Cond", size: 20.0)!
        friendsButton.titleLabel?.font = UIFont(name: "Proxima Nova Cond", size: 20.0)!
        logoutButton.titleLabel?.font = UIFont(name: "Proxima Nova Cond", size: 20.0)!
        removeAccountButton.titleLabel?.font = UIFont(name: "Proxima Nova Cond", size: 20.0)!
        
        recommendationsButton.titleLabel!.textColor = UIColor.whiteColor()
        friendsButton.titleLabel?.textColor = UIColor.whiteColor()
        logoutButton.titleLabel?.textColor = UIColor.whiteColor()
        removeAccountButton.titleLabel?.textColor = UIColor.whiteColor()
        
        recommendationsButton.backgroundColor = CommonUI.fbGreen
        friendsButton.backgroundColor = CommonUI.fbBlue
        logoutButton.backgroundColor = CommonUI.navbarGrayColor
        removeAccountButton.backgroundColor = CommonUI.navbarGrayColor
        
        
        
//        recommendationsButton
//        friendsButton
//        logoutButton
//        removeAccountButton
        
        recommendationsButton.layer.cornerRadius = 4.0
        friendsButton.layer.cornerRadius = 4.0
        logoutButton.layer.cornerRadius = 4.0
        removeAccountButton.layer.cornerRadius = 4.0
        
        nameLabel.sizeToFit()
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendationsButton.translatesAutoresizingMaskIntoConstraints = false
        friendsButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        removeAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        view.addSubview(recommendationsButton)
        view.addSubview(friendsButton)
        view.addSubview(logoutButton)
        view.addSubview(removeAccountButton)
        
        recommendationsButton.addTarget(
            self,
            action: #selector(ProfileViewController.recommendationsButtonPushed),
            forControlEvents: .TouchUpInside
        )
        friendsButton.addTarget(
            self,
            action: #selector(ProfileViewController.friendsButtonPushed),
            forControlEvents: .TouchUpInside
        )
        logoutButton.addTarget(
            self,
            action: #selector(ProfileViewController.logoutButtonPushed),
            forControlEvents: .TouchUpInside
        )
        removeAccountButton.addTarget(
            self,
            action: #selector(ProfileViewController.removeButtonPressed),
            forControlEvents: .TouchUpInside
        )
        
        addConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        navigationController?.toolbarHidden = false
        
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
        
        setToolbarItems()
    }
    
    func recommendationsButtonPushed() {
        navigationController?.pushViewController(YourRecommendationsViewController(), animated: true)
    }
    
    func friendsButtonPushed() {
        
    }
    
    func logoutButtonPushed() {
        UpdateBullshitter.instance.STAHP()
        FBSDKLoginManager().logOut()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func removeButtonPressed() {
        
    }
    
    /* Toolbar */
    
    func setToolbarItems() {
        let homeButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.home_image,
            style: .Plain,
            target: self,
            action: #selector(ProfileViewController.homeButtonPressed)
        )
        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
        
        smallProfilePicture.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        smallProfilePicture.contentMode = .ScaleAspectFit
        let profileButton: UIButton = UIButton(type: UIButtonType.Custom)
        profileButton.frame = smallProfilePicture.frame
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        profileButton.addSubview(smallProfilePicture)
        profileButton.addTarget(
            self,
            action: #selector(ProfileViewController.profileButtonPressed),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.fa_plus_square_image_fbGreen,
            style: .Plain,
            target: self,
            action: #selector(ProfileViewController.newRecommendationButtonPressed)
        )
        newRecommendationButton.tintColor = CommonUI.fbGreen
        
        toolbarItems = [homeButton, CommonUI.flexibleSpace, profileBBItem, CommonUI.flexibleSpace, newRecommendationButton]
    }
    
    func homeButtonPressed() {
        for viewController: UIViewController in navigationController!.viewControllers {
            if viewController.isKindOfClass(MainScreenViewController) {
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
    
    func profileButtonPressed() {
        return
    }
    
    func newRecommendationButtonPressed() {
        return
    }
    
    func addConstraints() {
        view.addConstraint(
            NSLayoutConstraint(
                item: largeProfilePicture,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 0.5,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: largeProfilePicture,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: nameLabel,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: nameLabel,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: largeProfilePicture,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: 12.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: recommendationsButton,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: friendsButton,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: logoutButton,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: friendsButton,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: removeAccountButton,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: friendsButton,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: logoutButton,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: -8.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: removeAccountButton,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 8.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: recommendationsButton,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nameLabel,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: 12.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: friendsButton,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: recommendationsButton,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: 12.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: logoutButton,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: friendsButton,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: 12.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: removeAccountButton,
                attribute: NSLayoutAttribute.Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: friendsButton,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: 12.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: recommendationsButton,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.9,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: friendsButton,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.9,
                constant: 0.0))
    }
    
}
