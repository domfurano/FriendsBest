//
//  MainView.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class MainView: UIView {
    
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)

        CGContextSetFillColorWithColor(context, UIColor.lightGrayColor().CGColor)
        CGContextFillRect(context, bounds)
        
        /* Initialize views */
        
        /* Subviews */
        
//        setConstraints()
    }
    
    /* Constraints */
    
//    func setConstraints() {
//        self.addConstraint(
//            NSLayoutConstraint(
//                item: searchBar,
//                attribute: NSLayoutAttribute.Height,
//                relatedBy: NSLayoutRelation.LessThanOrEqual,
//                toItem: self,
//                attribute: NSLayoutAttribute.Height,
//                multiplier: 1.0,
//                constant: 0.0))
//        
//        self.addConstraint(
//            NSLayoutConstraint(
//                item: searchBar,
//                attribute: NSLayoutAttribute.Width,
//                relatedBy: NSLayoutRelation.LessThanOrEqual,
//                toItem: self,
//                attribute: NSLayoutAttribute.Width,
//                multiplier: 1.0,
//                constant: 0.0))
//    }
}
