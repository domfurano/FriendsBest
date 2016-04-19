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
    
    let whiteLogo: UIImageView = UIImageView(image: UIImage(named: "logo-white.png")!)
    let title: UILabel = UILabel()
    var loginButton: FBSDKLoginButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(loginButton: FBSDKLoginButton) {
        self.init(frame: CGRectZero)
        self.loginButton = loginButton
        
        title.text = "FriendsBest let's you search and share recommendations with your Facebook friends."
        title.numberOfLines = 2
        title.textAlignment = .Center
        title.textColor = UIColor.whiteColor()
        title.font = UIFont(name: "Proxima Nova Cond", size: 16.0)
        
        whiteLogo.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(whiteLogo)
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
        
        CommonUI.drawGradientForContext(
            [
                UIColor.colorFromHex(0x48ABE1).CGColor,
                UIColor.colorFromHex(0x3B5998).CGColor
            ],
            frame: self.bounds,
            context: context
        )
    }
    
    private func addConstraints() {
        addConstraint(
            NSLayoutConstraint(
                item: whiteLogo,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Width,
                multiplier: 0.5,
                constant: 0.0))
        
        addConstraint(
            NSLayoutConstraint(
                item: whiteLogo,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: whiteLogo,
                attribute: .Width,
                multiplier: 1.0,
                constant: 0.0))
        
        addConstraint(
            NSLayoutConstraint(
                item: whiteLogo,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1.0,
                constant: 32.0))
        
        addConstraint(
            NSLayoutConstraint(
                item: whiteLogo,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        
        self.addConstraint(
            NSLayoutConstraint(
                item: title,
                attribute: .Top,
                relatedBy: NSLayoutRelation.Equal,
                toItem: whiteLogo,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 32.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: title,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Width,
                multiplier: 0.8,
                constant: 0.0))
        
//        self.addConstraint(
//            NSLayoutConstraint(
//                item: title,
//                attribute: NSLayoutAttribute.Height,
//                relatedBy: NSLayoutRelation.Equal,
//                toItem: self,
//                attribute: NSLayoutAttribute.Height,
//                multiplier: 0.1,
//                constant: 0.0))
        
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
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Bottom,
                multiplier: 1.0,
                constant: -64.0))
    }

    
}
