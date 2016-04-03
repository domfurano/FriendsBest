//
//  ComminUIElements.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/11/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit


class GradientTableView: UITableView {
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)
        
        CommonUI.drawGradientForContext(
            [
                CommonUI.topGradientColor,
                CommonUI.bottomGradientColor
            ],
            frame: self.bounds,
            context: context
        )
    }
}


class CommonUI {
    
    static let instance: CommonUI = CommonUI()
    
    static let ICON_FLOAT: CGFloat = 32.0 // TODO: Use this everywhere
    static let ICON_SIZE: CGSize = CGSize(width: ICON_FLOAT, height: ICON_FLOAT)
    static let fbGreen: UIColor = UIColor.colorFromHex(0x59C939)
    static let fbBlue: UIColor = UIColor.colorFromHex(0x3B5998)
    static var UITextFieldFontName: String = "Helvetica Neue"
    static let UITextFieldFontSize: CGFloat = 14.0
    
    static var largeProfilePicture: UIImageView? {
        if _largeProfilePicture == nil {
            return nil
        } else {
            return UIImageView.init(image: UIImage(CGImage: _largeProfilePicture!.image!.CGImage!))
        }
    }
    
    static var smallProfilePicture: UIImageView? {
        if _smallProfilePicture == nil {
            return nil
        } else {
            return UIImageView.init(image: UIImage(CGImage: _smallProfilePicture!.image!.CGImage!))
        }
    }
    
    private static var _largeProfilePicture: UIImageView?
    private static var _smallProfilePicture: UIImageView?
    static var friendNormalProfilePictures: Dictionary<Friend, UIImageView> = Dictionary()
    
    static let navbarGrayColor: UIColor = UIColor.colorFromHex(0xABB4BA)
    static let navbarBlueColor: UIColor = UIColor.colorFromHex(0x3B5998)
    static let toolbarLightColor: UIColor = UIColor.colorFromHex(0xE8EDEF)
    
    // Navigation bar back chevron
    static let nbBackChevron: UIImage = FAKFontAwesome.chevronLeftIconWithSize(ICON_FLOAT).imageWithSizeAndColor(ICON_SIZE, color: UIColor.whiteColor())
    static let nbTimes: UIImage = FAKFontAwesome.timesIconWithSize(ICON_FLOAT).imageWithSize(ICON_SIZE)
    
    /* Gradient colors for views */
    static let topGradientColor: CGColor = UIColor.whiteColor().CGColor
    static let bottomGradientColor: CGColor = UIColor.colorFromHex(0xe8edef).CGColor
    
    /* Toolbar */
    static let home_image: UIImage = FAKFontAwesome.homeIconWithSize(ICON_FLOAT).imageWithSize(ICON_SIZE)
    static let fa_plus_square_image_fbGreen: UIImage = FAKFontAwesome.plusSquareIconWithSize(ICON_FLOAT).imageWithSizeAndColor(ICON_SIZE, color: fbGreen)
    static let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    
    /* Solution Detail */
    static let sdNavbarBgColor: UIColor = UIColor.colorFromHex(0x666666)
    
    /* web type */
    static let globeView: UIImageView = UIImageView(image: FAKFontAwesome.globeIconWithSize(16.0).imageWithSize(CGSize(width: 30.0, height: 30.0)))
    
    private init() {
        FacebookNetworkDAO.instance.getFacebookProfileImageView(
            User.instance.facebookID!,
            size: FacebookNetworkDAO.FacbookImageSize.large
        ) { (profileImageView: UIImageView) in
            CommonUI._largeProfilePicture = profileImageView
        }
        FacebookNetworkDAO.instance.getFacebookProfileImageView(
            User.instance.facebookID!,
            size: FacebookNetworkDAO.FacbookImageSize.small
        ) { (profileImageView: UIImageView) in
            CommonUI._smallProfilePicture = profileImageView
        }
    }
    
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
        let button: UIButton = UIButton(frame: CGRectMake(0, 0, ICON_FLOAT, ICON_FLOAT))
        let historyIcon: FAKFontAwesome = FAKFontAwesome.historyIconWithSize(ICON_FLOAT)
        historyIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromHex(0xabb4ba))
        if alert {
            let alertIcon: FAKFontAwesome = FAKFontAwesome.circleIconWithSize(18)
            alertIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor())
            let iconArray: [FAKIcon] = [
                historyIcon,
                alertIcon
            ]
            let image: UIImage = UIImage(stackedIcons: iconArray, imageSize: ICON_SIZE)
            button.setImage(image, forState: .Normal)
            return button
        } else {
            let image: UIImage = historyIcon.imageWithSize(ICON_SIZE)
            button.setImage(image, forState: .Normal)
            return button
        }
    }
    
}



































