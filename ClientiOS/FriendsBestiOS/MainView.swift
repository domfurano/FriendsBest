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
        
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = self.bounds
//        gradient.colors = [
//            UIColor.colorFromHex(0xfefefe),
//            UIColor.colorFromHex(0xe8eef0)
//        ]
        
        let colorSpace: CGColorSpaceRef? = CGColorSpaceCreateDeviceRGB()
        
        let gradient: CGGradientRef? = CGGradientCreateWithColors(
            colorSpace,
            [
                UIColor.colorFromHex(0xfefefe).CGColor,
                UIColor.colorFromHex(0xc8ced0).CGColor
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
        
//        CGContextSetFillColorWithColor(context, UIColor.colorFromHex(0xe8edef).CGColor)
//        CGContextFillRect(context, bounds)
    }
}
