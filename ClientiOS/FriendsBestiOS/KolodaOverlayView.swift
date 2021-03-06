//
//  File.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/21/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import Koloda

class KolodaOverlayView: OverlayView {
    
    let ICON_SIZE: CGFloat = 128.0
    var thumbsUpImageView: UIImageView!
    var thumbsDownImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        thumbsUpImageView = UIImageView(frame: bounds)
        thumbsDownImageView = UIImageView(frame: bounds)
        
        let thumbsUpIcon: FAKFontAwesome = FAKFontAwesome.plusSquareIconWithSize(ICON_SIZE)
        let thumbsDownIcon: FAKFontAwesome = FAKFontAwesome.timesCircleIconWithSize(ICON_SIZE)
        
        thumbsUpIcon.addAttribute(
            NSForegroundColorAttributeName,
            value: CommonUI.yesColor
        )
        
        thumbsDownIcon.addAttribute(
            NSForegroundColorAttributeName,
            value: CommonUI.noColor
        )
        
        let imageSize: CGSize = CGSize(width: ICON_SIZE, height: ICON_SIZE)
        let thumbsUpImage = thumbsUpIcon.imageWithSize(imageSize)
        let thumbsDownImage = thumbsDownIcon.imageWithSize(imageSize)
        
        thumbsUpImageView.image = thumbsUpImage
        thumbsDownImageView.image = thumbsDownImage
        
        thumbsUpImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbsDownImageView.translatesAutoresizingMaskIntoConstraints = false
        
        thumbsUpImageView.alpha = 0.0
        thumbsDownImageView.alpha = 0.0
        
        addSubview(thumbsUpImageView)
        addSubview(thumbsDownImageView)
        
        let offset: CGFloat = 16.0
        
        addConstraint(
            NSLayoutConstraint(
                item: thumbsUpImageView,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Left,
                multiplier: 1.0,
                constant: offset))
        
        addConstraint(
            NSLayoutConstraint(
                item: thumbsUpImageView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1.0,
                constant: offset))
        
        addConstraint(
            NSLayoutConstraint(
                item: thumbsDownImageView,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Right,
                multiplier: 1.0,
                constant: -offset))
        
        addConstraint(
            NSLayoutConstraint(
                item: thumbsDownImageView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1.0,
                constant: offset))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    

    override var overlayState: OverlayMode  {
        didSet {
            switch overlayState {
            case .Left :
                thumbsUpImageView.alpha = 0.0
                thumbsDownImageView.alpha = 1.0
            case .Right :
                thumbsUpImageView.alpha = 1.0
                thumbsDownImageView.alpha = 0.0
            default:
                NSLog("WTF")
            }
            
        }
    }

}
