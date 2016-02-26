//
//  BaseCard.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/9/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class BaseCardView: UIView {
    
    var friendsBestLabel: UILabel = UILabel()
    
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, self.bounds)
        
        CGContextSetFillColorWithColor(context, UIColor.colorFromHex(0xe8edef).CGColor)
        CGContextFillRect(context, self.bounds)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        
        /* UILabel */
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "FriendsBest")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue", size: 22.0)!, range: NSMakeRange(0, 7))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 22.0)!, range: NSMakeRange(7, 4))
        
        friendsBestLabel.attributedText = attributedString
        
        friendsBestLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(friendsBestLabel)
        
        self.addConstraint(
            NSLayoutConstraint(
                item: friendsBestLabel,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: friendsBestLabel,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
    }
}