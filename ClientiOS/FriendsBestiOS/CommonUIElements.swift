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
    
    static let ICON_SIZE: CGFloat = 32.0 // TODO: Use this everywhere
    
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

    
    static func tagLabel(tag: String) -> UILabel {
        let label: UILabel = UILabel()
        label.text = "  \(tag)  " // TODO: This is a hack. Probably want to subclass UILabel eventually
        label.backgroundColor = UIColor.colorFromHex(0xededed)
        label.layer.shadowOpacity = 0.33
        label.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        label.layer.shadowRadius = 1.0
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.colorFromHex(0xe5e7e8).CGColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    
    static func searchHistoryButton(alert: Bool) -> UIButton {
        let button: UIButton = UIButton(frame: CGRectMake(0, 0, ICON_SIZE, ICON_SIZE))
        let historyIcon: FAKFontAwesome = FAKFontAwesome.historyIconWithSize(ICON_SIZE)
        historyIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromHex(0xabb4ba))
        if alert {
            let alertIcon: FAKFontAwesome = FAKFontAwesome.circleIconWithSize(18)
            alertIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor())
            let iconArray: [FAKIcon] = [
                historyIcon,
                alertIcon
            ]
            let image: UIImage = UIImage(stackedIcons: iconArray, imageSize: CGSizeMake(ICON_SIZE, ICON_SIZE))
            button.setImage(image, forState: .Normal)
            return button
        } else {
            let image: UIImage = historyIcon.imageWithSize(CGSize(width: ICON_SIZE, height: ICON_SIZE))
            button.setImage(image, forState: .Normal)
            return button
        }
    }
    
}








































