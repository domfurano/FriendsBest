//
//  ComminUIElements.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/11/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import PINRemoteImage


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
    static let fa_plus_square_image: UIImage = FAKFontAwesome.plusSquareIconWithSize(ICON_FLOAT).imageWithSize(ICON_SIZE)
    static let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    
    /* Solution Detail */
    static let sdNavbarBgColor: UIColor = UIColor.colorFromHex(0x666666)
    
    /* Link type picker */
    static let globeView: UIImageView = UIImageView(image: FAKFontAwesome.globeIconWithSize(16.0).imageWithSize(CGSize(width: 30.0, height: 30.0)))
    static let wvBackChevron: UIImage = FAKFontAwesome.chevronLeftIconWithSize(ICON_FLOAT).imageWithSize(ICON_SIZE)
    static let wvForwardChevron: UIImage = FAKFontAwesome.chevronRightIconWithSize(ICON_FLOAT).imageWithSize(ICON_SIZE)
    static let wvRefresh: UIImage = FAKFontAwesome.repeatIconWithSize(ICON_FLOAT).imageWithSize(ICON_SIZE)
    
    /* Prompt cards */
    static let noColor: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
    static let yesColor: UIColor = UIColor(red: 0.35, green: 0.79, blue: 0.22, alpha: 0.5)
    
    /* Facebook profile pictures */
    enum FacbookImageSize: String {
        case small = "small"
        case normal = "normal"
        case album = "album"
        case large = "large"
        case square = "square"
    }
    
    /* Images */
    var largePicture: UIImageView {
        get {
            return CommonUI.instance.getFacebookProfileUIImageView(User.instance.facebookID, size: CGSize(width: 200, height: 200))
        }
    }
    var squarePicture: UIImageView {
        get {
            return CommonUI.instance.getFacebookProfileUIImageView(User.instance.facebookID, size: CommonUI.FacbookImageSize.square)
        }
    }
    
    private init() { }
    
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
        label.font = UIFont(name: "Proxima Nova Cond", size: 16.0)
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
    
    func getFacebookProfileUIImageView(facebookID: String, size: FacbookImageSize) -> UIImageView {
        let facebookProfileUIImageView: UIImageView = UIImageView()
        
        let pictureURL: NSURL? = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=\(size.rawValue)")
        
        if pictureURL != nil {
            facebookProfileUIImageView.pin_updateWithProgress = true
            facebookProfileUIImageView.pin_setImageFromURL(pictureURL, completion: { (result: PINRemoteImageManagerResult) in
                if result.image != nil {
                    facebookProfileUIImageView.image = result.image!.roundedImage()
                }
            })
        }
        
        return facebookProfileUIImageView
    }
    
    func getFacebookProfileUIImageView(facebookID: String, size: CGSize) -> UIImageView {
        let facebookProfileUIImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let pictureURL: NSURL? = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture??width=\(Int(size.width))&height=\(Int(size.height))")
        
        if pictureURL != nil {
            facebookProfileUIImageView.pin_updateWithProgress = true
            facebookProfileUIImageView.pin_setImageFromURL(pictureURL, completion: { (result: PINRemoteImageManagerResult) in
                if result.image != nil {
                    facebookProfileUIImageView.image = result.image!.roundedImage()
                }
            })
        }
        
        return facebookProfileUIImageView
    }
    
    func setUIButtonWithFacebookProfileImage(button: UIButton) {
        var facebookProfileUIImageView: UIImageView? = nil
        
        let pictureURL: NSURL? = NSURL(string: "https://graph.facebook.com/\(User.instance.facebookID)/picture?type=\(FacbookImageSize.square.rawValue)")
        
        if pictureURL != nil {
            facebookProfileUIImageView = UIImageView()
            facebookProfileUIImageView!.pin_updateWithProgress = true
            facebookProfileUIImageView!.pin_setImageFromURL(pictureURL, completion: { (result: PINRemoteImageManagerResult) in
                if result.image != nil {
                    button.setImage(result.image!.roundedImage(), forState: .Normal)
                }
            })
        }
    }
    
}

extension UIImage{
    
    func roundedImage() -> UIImage {
        let cornerRadius: CGFloat = min(self.size.width, self.size.height) / 2.0
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let bounds = CGRect(origin: CGPointZero, size: self.size)
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).addClip()
        self.drawInRect(bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
    
}

extension UIColor {
    static func colorFromHex(hex: Int) -> UIColor {
        return UIColor(red: ( (CGFloat)( (hex & 0xFF0000) >> 16) ) / 255.0,
                       green: ( (CGFloat)( (hex & 0x00FF00) >>  8) ) / 255.0,
                       blue: ( (CGFloat)( (hex & 0x0000FF) >>  0) ) / 255.0,
                       alpha: 1.0)
    }
}































