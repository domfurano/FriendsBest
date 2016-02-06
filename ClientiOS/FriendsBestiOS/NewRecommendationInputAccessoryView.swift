//
//  NewRecommendation.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/4/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class NewRecommendationInputAccessoryView: UIView {
    
    var recommendButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 11))
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        self.layoutMargins = UIEdgeInsetsMake(2, 8, 2, 8)
        
        recommendButton = UIButton(type: UIButtonType.System)
        recommendButton?.setTitle("Recommend", forState: UIControlState.Normal)
        recommendButton?.setTitleColor(UIColor.colorFromHex(0x007aff), forState: UIControlState.Normal)
        recommendButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        recommendButton?.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 20.0)
        
        recommendButton?.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(recommendButton!)
        
        addConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        self.addConstraint(
            NSLayoutConstraint(
                item: recommendButton!,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
        self.addConstraint(
            NSLayoutConstraint(
                item: recommendButton!,
                attribute: NSLayoutAttribute.Right,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1.0,
                constant: -16.0))
        
//        self.addConstraint(
//            NSLayoutConstraint(
//                item: recommendButton!,
//                attribute: NSLayoutAttribute.,
//                relatedBy: NSLayoutRelation.Equal,
//                toItem: self,
//                attribute: NSLayoutAttribute.Right,
//                multiplier: 1.0,
//                constant: 0.0))
    }
    
    
//    private func inputAccessoryView() -> UIView {
//        let accessFrame: CGRect = CGRectMake(0.0, 0.0, 768.0, 77.0)
//        let inputAccessoryView: UIView = UIView(frame: accessFrame)
//        inputAccessoryView.backgroundColor = UIColor.blueColor()
//        let compButton: UIButton = UIButton(type: UIButtonType.RoundedRect)
//        compButton.frame = CGRectMake(313.0, 20.0, 158.0, 37.0)
//        compButton.setTitle("Word Completions", forState: UIControlState.Normal)
//        compButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        compButton.addTarget(self, action: Selector("completeCurrentWord"), forControlEvents: UIControlEvents.TouchUpInside)
//        inputAccessoryView.addSubview(compButton)
//        return inputAccessoryView;
//    }
    
}
