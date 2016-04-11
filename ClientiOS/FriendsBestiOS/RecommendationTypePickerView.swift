//
//  RecommendationTypePicker.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/3/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class RecommendationTypePickerView: UIView {
    
    var customLabel: UILabel = UILabel()
    var linkLabel: UILabel = UILabel()
    var placeLabel: UILabel = UILabel()
    
    var customTypeButton: UIButton = UIButton()
    var linkTypeButton: UIButton = UIButton()
    var placeTypeButton: UIButton = UIButton()
    
    var visibleContstraints: [NSLayoutConstraint] = []
    var hiddenConstraints: [NSLayoutConstraint] = []
    
    final let labelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 18.0)!
    final let textColor: UIColor = UIColor.whiteColor()
    final let ICON_SIZE: CGFloat = 60.0
    final let ICON_COLOR: UIColor = CommonUI.fbGreen
    final let BUTTON_SIZE: CGSize = CGSize(width: 80.0, height: 80.0)
    final let BUTTON_BGCOLOR: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.33)
    final let BUTTON_CORNER_RADIUS: CGFloat = 4.0
    final let VISIBLE_COLOR: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.67)
    final let HIDDEN_COLOR: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    
    /* Delegation */
    var customButtonDelegate: () -> Void = { }
    var linkButtonDelegate: () -> Void = { }
    var placeButtonDelegate: () -> Void = { }
    var pickerHidden: () -> Void = { }
    
    convenience init() {
        self.init(frame: CGRectZero)
        
        backgroundColor = HIDDEN_COLOR
        
        customLabel.text = "Custom"
        linkLabel.text = "Website"
        placeLabel.text = "Place"
        
        customLabel.font = labelFont
        linkLabel.font = labelFont
        placeLabel.font = labelFont
        
        customLabel.textColor = textColor
        linkLabel.textColor = textColor
        placeLabel.textColor = textColor
        
        let iCursorIcon: FAKFontAwesome = FAKFontAwesome.iCursorIconWithSize(ICON_SIZE)
        let linkIcon: FAKFontAwesome = FAKFontAwesome.externalLinkIconWithSize(ICON_SIZE)
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
        
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        linkLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        customTypeButton.translatesAutoresizingMaskIntoConstraints = false
        linkTypeButton.translatesAutoresizingMaskIntoConstraints = false
        placeTypeButton.translatesAutoresizingMaskIntoConstraints = false
        
        customTypeButton.addTarget(
            self,
            action: #selector(RecommendationTypePickerView.customTypeButtonTouched),
            forControlEvents: UIControlEvents.TouchUpInside)
        
        linkTypeButton.addTarget(
            self,
            action: #selector(RecommendationTypePickerView.linkTypeButtonTouched),
            forControlEvents: UIControlEvents.TouchUpInside)
        
        placeTypeButton.addTarget(
            self,
            action: #selector(RecommendationTypePickerView.placeTypeButtonTouched),
            forControlEvents: UIControlEvents.TouchUpInside)
        
        addSubview(linkLabel)
        addSubview(placeLabel)
        addSubview(customLabel)
        addSubview(linkTypeButton)
        addSubview(placeTypeButton)
        addSubview(customTypeButton)
        
        addStaticConstraints()
        generateHiddenConstraints()
        generateVisibleConstraints()
        
        hide(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        hide(false)
    }
    
    func customTypeButtonTouched() {
        customButtonDelegate()
    }
    
    func linkTypeButtonTouched() {
        linkButtonDelegate()
    }
    
    func placeTypeButtonTouched() {
        placeButtonDelegate()
    }
    
    func show() {
        UIView.animateWithDuration(NSTimeInterval(0.33)) {
            self.backgroundColor = self.VISIBLE_COLOR
        }
        
        UIView.animateWithDuration(
            NSTimeInterval(0.5),
            delay: NSTimeInterval(0.0),
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {
                self.removeConstraints(self.hiddenConstraints)
                self.addConstraints(self.visibleContstraints)
                self.layoutIfNeeded()
        }) { (Bool) in
        }
    }
    
    var hiding: Bool = false
    func hide(immediately: Bool) {
        if hiding {
            return
        }
        
        hiding = true
        
        if immediately {
            hide()
            self.backgroundColor = self.HIDDEN_COLOR
            hiding = false
            self.pickerHidden()
        } else {
            UIView.animateWithDuration(NSTimeInterval(0.33)) {
                self.backgroundColor = self.HIDDEN_COLOR
            }
            
            UIView.animateWithDuration(
                NSTimeInterval(0.5),
                delay: NSTimeInterval(0.0),
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0,
                options: UIViewAnimationOptions.CurveEaseIn,
                animations: {
                    self.hide()
                    self.layoutIfNeeded()
            }) { (Bool) in
                self.hiding = false
                self.pickerHidden()
            }
        }
    }
    
    private func hide() {
        removeConstraints(visibleContstraints)
        addConstraints(hiddenConstraints)
    }
    
    private func addStaticConstraints() {
        
        addConstraint(
            NSLayoutConstraint(
                item: customLabel,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: customTypeButton,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0
            ))
        
        addConstraint(
            NSLayoutConstraint(
                item: linkLabel,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: linkTypeButton,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0
            ))
        
        addConstraint(
            NSLayoutConstraint(
                item: placeLabel,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: placeTypeButton,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0
            ))
        
        addConstraints([
            NSLayoutConstraint(
                item: customLabel,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: customTypeButton,
                attribute: .Top,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: linkLabel,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: linkTypeButton,
                attribute: .Top,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: placeLabel,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: placeTypeButton,
                attribute: .Top,
                multiplier: 1.0,
                constant: 0.0
            )])
        
        addConstraints([
            NSLayoutConstraint(
                item: customTypeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterY,
                multiplier: 1.5,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: linkTypeButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: placeTypeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterY,
                multiplier: 1.5,
                constant: 0.0
            )])
    }
    
    private func generateVisibleConstraints() {
        visibleContstraints.appendContentsOf([
            NSLayoutConstraint(
                item: customTypeButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX,
                multiplier: 0.33,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: linkTypeButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterY,
                multiplier: 1.5,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: placeTypeButton,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX,
                multiplier: 1.67,
                constant: 0.0
            )])
    }
    
    private func generateHiddenConstraints() {
        hiddenConstraints.appendContentsOf([
            NSLayoutConstraint(
                item: customTypeButton,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Left,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: linkLabel,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: placeTypeButton,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Right,
                multiplier: 1.0,
                constant: 0.0
            )])
    }
    
}
