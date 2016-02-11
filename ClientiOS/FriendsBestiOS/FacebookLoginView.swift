//
//  FacebookLoginView.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/1/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookLoginView: UIView {
    
    let title: UILabel = UILabel()
    var loginButton: FBSDKLoginButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(loginButton: FBSDKLoginButton) {
        self.init(frame: CGRectZero)
        self.loginButton = loginButton
        
        title.text = "FriendsBest"
        title.textColor = UIColor.whiteColor()
        title.font = UIFont.boldSystemFontOfSize(50.0)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(title)
        self.addSubview(loginButton)
        
        addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)
        
        CGContextSetFillColorWithColor(context, UIColor.lightGrayColor().CGColor)
        CGContextFillRect(context, bounds)
    }
    
    private func addConstraints() {
        self.addConstraint(
            NSLayoutConstraint(
                item: title,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 0.5,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: title,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.1,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: title,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: loginButton!,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: loginButton!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.5,
                constant: 0.0))
    }

    
}
