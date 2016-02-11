//
//  ComminUIElements.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/11/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class CommonUIElements {
    
    static func drawGradientForContext(colors: [CGColor], frame: CGRect, context: CGContext) {
        let colorSpace: CGColorSpaceRef? = CGColorSpaceCreateDeviceRGB()
        
        let gradient: CGGradientRef? = CGGradientCreateWithColors(
            colorSpace,
            colors,
            nil
        )
        
        CGContextDrawLinearGradient(
            context,
            gradient,
            CGPoint(x: frame.midX, y: 0),
            CGPoint(x: frame.midX, y: frame.maxY),
            CGGradientDrawingOptions.DrawsAfterEndLocation
        )
    }
    
    static func queryHistoryCell() -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "queryCell")
        
        cell.backgroundColor = UIColor.clearColor()

        
        let customContentView: UIView = UIView(frame: cell.contentView.frame.insetBy(dx: 2, dy: 2))
        customContentView.backgroundColor = UIColor.colorFromHex(0xaaaaaa)
        customContentView.layer.borderColor = UIColor.colorFromHex(0x999999).CGColor
        customContentView.layer.borderWidth = 2
        customContentView.layer.shadowColor = UIColor.colorFromHex(0xff0000).CGColor

        cell.contentView.addSubview(customContentView)
        
        
        return cell
    }

}








































