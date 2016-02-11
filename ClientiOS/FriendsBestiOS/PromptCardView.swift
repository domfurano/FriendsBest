//
//  Card.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/9/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class PromptCardView: UIView {
    var titleLabel: UILabel = UILabel()
    var tagLabel: UILabel = UILabel()
    var subTitleLabel: UILabel = UILabel()
    
    //    var userPicture: UIView?
    
    var prompt: Prompt?
    
    func drawLinearGradient(context: CGContext) {
        let colorSpace: CGColorSpaceRef? = CGColorSpaceCreateDeviceRGB()
        
        let gradient: CGGradientRef? = CGGradientCreateWithColors(
            colorSpace,
            [
                UIColor.colorFromHex(0xd5dadc).CGColor,
                UIColor.colorFromHex(0xaab4bb).CGColor
            ],
            nil
        )
        
        CGContextDrawLinearGradient(
            context,
            gradient,
            CGPoint(x: self.frame.midX, y: 0),
            CGPoint(x: self.frame.midX, y: self.frame.maxY),
            CGGradientDrawingOptions.DrawsAfterEndLocation
        )
    }
    
    
    override func drawRect(rect: CGRect) {
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, self.bounds)
        
        drawLinearGradient(context)
        
//        CGContextSetAllowsAntialiasing(context, true)
//        CGContextSetShouldAntialias(context, true)
        
        /* Rotate */
        let angleInRadians: CGFloat = CGFloat((Int32(random()) - INT32_MAX / 2) % (INT32_MAX / 32)) / CGFloat(INT32_MAX)
        let transform: CGAffineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, angleInRadians)
        self.transform = transform
        
        /* Rounded corners */
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8.0
        
        /* Border */
        
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.colorFromHex(0xaaaaaa).CGColor
        
        /* UILabels */
        
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "Helvetica Neue", size: 16.0)
        
        tagLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 22.0)
        
        subTitleLabel.font = UIFont(name: "Helvetica Neue", size: 10.0)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "based on a search by \(prompt!.friend)")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue", size: 10.0)!, range: NSMakeRange(0, 20))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 10.0)!, range: NSMakeRange(21, prompt!.friend.characters.count))
        
        titleLabel.text = "Do you have a\nrecommendation for a"
        tagLabel.text = self.prompt?.tagString
        subTitleLabel.attributedText = attributedString
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(titleLabel)
        self.addSubview(tagLabel)
        self.addSubview(subTitleLabel)
        
        self.addConstraint(
            NSLayoutConstraint(
                item: titleLabel,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: titleLabel,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 0.15,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: tagLabel,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: tagLabel,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: subTitleLabel,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: subTitleLabel,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.9,
                constant: 0.0))
        
        //        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "FriendsBest")
        //        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue", size: 22.0)!, range: NSMakeRange(0, 7))
        //        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 22.0)!, range: NSMakeRange(7, 4))
        //
        //        friendsBestLabel.attributedText = attributedString
        //
        //        friendsBestLabel.translatesAutoresizingMaskIntoConstraints = false
        //
        //        self.addSubview(friendsBestLabel)
        //
        //        self.addConstraint(
        //            NSLayoutConstraint(
        //                item: friendsBestLabel,
        //                attribute: NSLayoutAttribute.CenterX,
        //                relatedBy: NSLayoutRelation.Equal,
        //                toItem: self,
        //                attribute: NSLayoutAttribute.CenterX,
        //                multiplier: 1.0,
        //                constant: 0.0))
        //
        //        self.addConstraint(
        //            NSLayoutConstraint(
        //                item: friendsBestLabel,
        //                attribute: NSLayoutAttribute.CenterY,
        //                relatedBy: NSLayoutRelation.Equal,
        //                toItem: self,
        //                attribute: NSLayoutAttribute.CenterY,
        //                multiplier: 1.0,
        //                constant: 0.0))
    }
    
}
