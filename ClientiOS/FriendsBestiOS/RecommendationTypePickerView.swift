//
//  RecommendationTypePicker.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/3/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class RecommendationTypePickerView: UIView {
    
    var customTypeButton: UIButton = UIButton()
    var linkTypeButton: UIButton = UIButton()
    var placeTypeButton: UIButton = UIButton()
    
    var visibleContstraints: [NSLayoutConstraint]? = nil
    var hiddenConstraints: [NSLayoutConstraint]? = nil
    
    final let ICON_SIZE: CGFloat = 60.0
    final let ICON_COLOR: UIColor = UIColor.colorFromHex(0x00d735)
    final let BUTTON_SIZE: CGSize = CGSize(width: 80.0, height: 80.0)
    final let BUTTON_BGCOLOR: UIColor = UIColor.grayColor()
    final let BUTTON_CORNER_RADIUS: CGFloat = 4.0
    final let BUTTON_VISIBLE_ALPHA: CGFloat = 0.8
    
    
    convenience init() {
        self.init(frame: CGRectZero)
        
        backgroundColor = UIColor.grayColor()
        alpha = 0.0
        customTypeButton.alpha = 0.0
        linkTypeButton.alpha = 0.0
        placeTypeButton.alpha = 0.0
        
        let iCursorIcon: FAKFontAwesome = FAKFontAwesome.iCursorIconWithSize(ICON_SIZE)
        let linkIcon: FAKFontAwesome = FAKFontAwesome.linkIconWithSize(ICON_SIZE)
        let mapOIcon: FAKFontAwesome = FAKFontAwesome.mapOIconWithSize(ICON_SIZE)
        
        iCursorIcon.addAttribute(NSForegroundColorAttributeName, value: ICON_COLOR)
        linkIcon.addAttribute(NSForegroundColorAttributeName, value: ICON_COLOR)
        mapOIcon.addAttribute(NSForegroundColorAttributeName, value: ICON_COLOR)
        
        let iCursorIconImage: UIImage = iCursorIcon.imageWithSize(BUTTON_SIZE)
        let linkIconImage: UIImage = linkIcon.imageWithSize(BUTTON_SIZE)
        let mapOIconImage: UIImage = mapOIcon.imageWithSize(BUTTON_SIZE)
        
        customTypeButton.setImage(iCursorIconImage, forState: .Normal)
        linkTypeButton.setImage(linkIconImage, forState: .Normal)
        placeTypeButton.setImage(mapOIconImage, forState: .Normal)
        
        customTypeButton.backgroundColor = BUTTON_BGCOLOR
        linkTypeButton.backgroundColor = BUTTON_BGCOLOR
        placeTypeButton.backgroundColor = BUTTON_BGCOLOR
        
        customTypeButton.layer.cornerRadius = BUTTON_CORNER_RADIUS
        linkTypeButton.layer.cornerRadius = BUTTON_CORNER_RADIUS
        placeTypeButton.layer.cornerRadius = BUTTON_CORNER_RADIUS
        
        customTypeButton.translatesAutoresizingMaskIntoConstraints = false
        linkTypeButton.translatesAutoresizingMaskIntoConstraints = false
        placeTypeButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func show() {
        if hiddenConstraints == nil {
            generateHiddenConstraints()
        }
        if visibleContstraints == nil {
            generateVisibleConstraints()
        }
        
        superview!.removeConstraints(hiddenConstraints!)
        superview!.addConstraints(visibleContstraints!)
        alpha = 0.0
        customTypeButton.alpha = BUTTON_VISIBLE_ALPHA
        linkTypeButton.alpha = BUTTON_VISIBLE_ALPHA
        placeTypeButton.alpha = BUTTON_VISIBLE_ALPHA
    }
    
    func hide() {
        if hiddenConstraints == nil {
            generateHiddenConstraints()
        }
        if visibleContstraints == nil {
            generateVisibleConstraints()
        }
        
        superview!.removeConstraints(visibleContstraints!)
        superview!.addConstraints(hiddenConstraints!)
        alpha = 0.0
        customTypeButton.alpha = 0.0
        linkTypeButton.alpha = 0.0
        placeTypeButton.alpha = 0.0
    }
    
    private func generateVisibleConstraints() {
        visibleContstraints = []
        visibleContstraints!.appendContentsOf([
            NSLayoutConstraint(
                item: customTypeButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterX,
                multiplier: 0.33,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: linkTypeButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: placeTypeButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterX,
                multiplier: 1.67,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: customTypeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterY,
                multiplier: 1.5,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: linkTypeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterY,
                multiplier: 1.5,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: placeTypeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterY,
                multiplier: 1.5,
                constant: 0.0
            )
            ])
    }
    
    private func generateHiddenConstraints() {
        hiddenConstraints = []
        hiddenConstraints!.appendContentsOf([
            NSLayoutConstraint(
                item: customTypeButton,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .Left,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: linkTypeButton,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: placeTypeButton,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .Right,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: customTypeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterY,
                multiplier: 1.5,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: linkTypeButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: placeTypeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: superview,
                attribute: .CenterY,
                multiplier: 1.5,
                constant: 0.0
            )
            ])
    }
    
}
