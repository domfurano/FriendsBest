//
//  NewRecommendation.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/4/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class NewRecommendationInputAccessoryView: UIView {
    
    var prevButton: UIButton?
    var nextButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 11))
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        self.layoutMargins = UIEdgeInsetsMake(2, 8, 2, 8)
        
        prevButton = UIButton(type: UIButtonType.System)
        prevButton!.setTitle("prev", forState: UIControlState.Normal)
        prevButton!.setTitleColor(UIColor.colorFromHex(0x007aff), forState: UIControlState.Normal)
        prevButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        prevButton!.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20.0)
        
        nextButton = UIButton(type: UIButtonType.System)
        nextButton!.setTitle("next", forState: UIControlState.Normal)
        nextButton!.setTitleColor(UIColor.colorFromHex(0x007aff), forState: UIControlState.Normal)
        nextButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        nextButton!.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20.0)
        
        prevButton?.translatesAutoresizingMaskIntoConstraints = false
        nextButton?.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(prevButton!)
        self.addSubview(nextButton!)
        
        addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hidePrevButton() {
        
    }
    
    private func addConstraints() {
        self.addConstraint(
            NSLayoutConstraint(
                item: prevButton!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: prevButton!,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: 16.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: nextButton!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: nextButton!,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1.0,
                constant: -16.0))
        
    }
}






























