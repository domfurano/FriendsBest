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
    }
}
