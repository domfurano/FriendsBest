//
//  Card.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/9/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import Koloda
import PINRemoteImage

class PromptCardView: UIView {
    
    var titleLabel: UILabel = UILabel()
    var tagLabel: UILabel = UILabel()
    var subTitleLabel: UILabel = UILabel()
    var friendPicture: UIImageView?
    
    //    var userPicture: UIView?
    
    var prompt: Prompt!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, prompt: Prompt) {
        self.init(frame: frame)
        self.prompt = prompt
        
        
        /* Rounded corners */
        
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        
        
        /* Border */
        
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.colorFromHex(0xaaaaaa).CGColor
        
        
        /* UI Elements */
        
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: "Proxima Nova Cond", size: 14.0)!
        
        tagLabel.font = UIFont(name: "ProximaNovaCond-Bold", size: 28.0)!
        tagLabel.numberOfLines = 2
        tagLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        
        var attributedString: NSMutableAttributedString
        if prompt.friend != nil {
            attributedString = NSMutableAttributedString(string: "based on a search by \(prompt.friend!.name)")
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Proxima Nova Cond", size: 14.0)!, range: NSMakeRange(0, 20))
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaCond-Bold", size: 14.0)!, range: NSMakeRange(21, prompt.friend!.name.characters.count))
        } else {
            attributedString = NSMutableAttributedString(string: "based on a search")
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "Proxima Nova Cond", size: 14.0)!, range: NSMakeRange(0, 17))
        }
        
        if prompt.friend != nil {
            friendPicture = prompt.friend!.smallRoundedPicture
        }
        
        titleLabel.text = "Do you have a recommendation for"
        tagLabel.text = self.prompt!.tagString//.isEmpty ? self.prompt!.tags.joinWithSeparator(" ") : self.prompt!.tagString
        subTitleLabel.attributedText = attributedString
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        friendPicture?.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(tagLabel)
        addSubview(subTitleLabel)
        if friendPicture != nil {
            addSubview(friendPicture!)
        }
        
        
        /* Layout contstraints */
        
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
                item: titleLabel,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.LessThanOrEqual,
                toItem: self,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.9,
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
                item: tagLabel,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.LessThanOrEqual,
                toItem: self,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.9,
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
                multiplier: 1.85,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: subTitleLabel,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.LessThanOrEqual,
                toItem: self,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.9,
                constant: 0.0))
        
        if friendPicture != nil {
            self.addConstraint(
                NSLayoutConstraint(
                    item: friendPicture!,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: subTitleLabel,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1.0,
                    constant: 0.0))
            
            self.addConstraint(
                NSLayoutConstraint(
                    item: friendPicture!,
                    attribute: NSLayoutAttribute.Leading,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: subTitleLabel,
                    attribute: NSLayoutAttribute.Trailing,
                    multiplier: 1.0,
                    constant: 12.0))
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, self.bounds)
        
        CommonUI.drawGradientForContext(
            [
                UIColor.colorFromHex(0xD7DBDD).CGColor,
                UIColor.colorFromHex(0xABB4BA).CGColor
            ],
            frame: self.frame,
            context: context
        )
    }
    
    
    
}


























