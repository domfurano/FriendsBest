//
//  Card.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/9/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import Koloda

class PromptCardView: KolodaView {

    var titleLabel: UILabel = UILabel()
    var tagLabel: UILabel = UILabel()
    var subTitleLabel: UILabel = UILabel()
    
    //    var userPicture: UIView?
    
    var prompt: Prompt?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, prompt: Prompt) {
        self.init(frame: frame)        
        self.prompt = prompt
        
        
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
        
        tagLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        
        subTitleLabel.font = UIFont(name: "Helvetica Neue", size: 10.0)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "based on a search by \(prompt.friend.name)")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue", size: 10.0)!, range: NSMakeRange(0, 20))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Bold", size: 10.0)!, range: NSMakeRange(21, prompt.friend.name.characters.count))
        
        titleLabel.text = "Do you have a\nrecommendation for a"
        tagLabel.text = self.prompt!.tagString
        subTitleLabel.attributedText = attributedString
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(titleLabel)
        self.addSubview(tagLabel)
        self.addSubview(subTitleLabel)
        
        
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


























