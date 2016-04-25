//
//  SolutionCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/7/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import PureLayout
import GoogleMaps

class SolutionCell: UITableViewCell {
    
    var background: UIView = UIView.newAutoLayoutView()
    var titleLabel: UILabel = UILabel.newAutoLayoutView()
    var subtitleLabel: UILabel = UILabel.newAutoLayoutView()
    var notification: UIImageView = UIImageView.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        selectionStyle = .None // No distinct style when selected
        backgroundColor = UIColor.clearColor()
        
        contentView.backgroundColor = UIColor.clearColor()
        
        background.layer.cornerRadius = 2.0
        background.layer.shadowOpacity = 0.33
        background.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        background.backgroundColor = UIColor.colorFromHex(0xDEDEDE)
        
        titleLabel.font = UIFont(name: "Proxima Nova Cond", size: 16.0)!
        
        subtitleLabel.font = UIFont(name: "Proxima Nova Cond", size: 12.0)!
        subtitleLabel.textColor = UIColor.darkGrayColor()
        
        let alertIcon: FAKFontAwesome = FAKFontAwesome.circleIconWithSize(18)
        alertIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor())
        let alertImage: UIImage = alertIcon.imageWithSize(CGSize(width: 18.0, height: 18.0))
        notification.image = alertImage
        
        contentView.addSubview(background)
        background.addSubview(titleLabel)
        background.addSubview(subtitleLabel)
        background.addSubview(notification)
    }
    
    func setupForViewing(showAlert: Bool) {
        if showAlert {
            notification.alpha = 1.0
        } else {
            notification.alpha = 0.0
        }
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    
    var didUpdateContraints: Bool = false
    override func updateConstraints() {
        if !didUpdateContraints {
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: {
                self.background.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.titleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.subtitleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            })
            
            let backgroundVerticalInset: CGFloat = 8.0
            let backgroundHorizontalInset: CGFloat = 16.0
            background.autoPinEdgeToSuperviewEdge(.Top, withInset: backgroundVerticalInset)
            background.autoPinEdgeToSuperviewEdge(.Leading, withInset: backgroundHorizontalInset)
            background.autoPinEdgeToSuperviewEdge(.Trailing, withInset: backgroundHorizontalInset)
            background.autoPinEdgeToSuperviewEdge(.Bottom, withInset: backgroundVerticalInset)
            
            let detailVerticalInset: CGFloat = 10.0
            let detailHorizontalInset: CGFloat = 18.0
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: detailVerticalInset)
            titleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: detailHorizontalInset)
//            titleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: detailHorizontalInset)
            titleLabel.autoPinEdge(.Trailing, toEdge: .Leading, ofView: notification, withOffset: 8.0, relation: .LessThanOrEqual)
            
            subtitleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 0.2, relation: .GreaterThanOrEqual)
            subtitleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: detailHorizontalInset)
//            subtitleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: detailHorizontalInset)
            subtitleLabel.autoPinEdge(.Trailing, toEdge: .Leading, ofView: notification, withOffset: 8.0, relation: .LessThanOrEqual)
            subtitleLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: detailVerticalInset)
            
            notification.autoAlignAxisToSuperviewAxis(.Horizontal)
            notification.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 8.0)
        }
        super.updateConstraints()
    }
}
