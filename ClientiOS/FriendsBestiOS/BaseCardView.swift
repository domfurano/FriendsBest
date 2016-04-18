//
//  BaseCard.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/9/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class BaseCardView: UIView {
    
    var whiteLogo: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.shadowColor = UIColor.colorFromHex(0xD3D7DA).CGColor
        
        /* Logo */
        whiteLogo = UIImageView(image: UIImage(named: "logo-white.png")!)
        addSubview(whiteLogo!)
        whiteLogo!.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(
            NSLayoutConstraint(
                item: whiteLogo!,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: whiteLogo!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: whiteLogo!,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.5,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: whiteLogo!,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: whiteLogo!,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1.0,
                constant: 0.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, self.bounds)
        CGContextSetFillColorWithColor(context, UIColor.colorFromHex(0xe8edef).CGColor)
        CGContextFillRect(context, self.bounds)
    }
    
    override func didMoveToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        
        superview!.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: superview!,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        superview!.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: superview!,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
        superview!.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: superview!,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.9,
                constant: 0.0))
        
        superview!.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: superview!,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.9,
                constant: 0.0))
    }
}