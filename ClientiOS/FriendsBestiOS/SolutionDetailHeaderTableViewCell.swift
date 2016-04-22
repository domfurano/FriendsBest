
//
//  SolutionDetailHeaderTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/16/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import PureLayout
import GoogleMaps

class SolutionDetailHeaderTableViewCell: UITableViewCell {
    var titleLabel: UILabel = UILabel.newAutoLayoutView()
    var subtitleLabel: UILabel = UILabel.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = false
        
        contentView.backgroundColor = CommonUI.sdNavbarBgColor
        
        titleLabel = UILabel.newAutoLayoutView()
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "ProximaNovaCond-Bold", size: 18.0)
        titleLabel.textColor = UIColor.whiteColor()
        
        subtitleLabel = UILabel.newAutoLayoutView()
        subtitleLabel.font = UIFont(name: "Proxima Nova Cond", size: 14.0)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = UIColor.whiteColor()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupForCellDisplay(title: String, subtitle: String) {
        titleLabel.text = title.isEmpty ? " " : title
        subtitleLabel.text = subtitle.isEmpty ? " " : subtitle
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: {
                self.titleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.subtitleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            })
        
            let horizontalInsets: CGFloat = 15.0
            let verticalInsets: CGFloat = 10.0
            
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
            titleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            titleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            
            subtitleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: verticalInsets, relation: .GreaterThanOrEqual)
            subtitleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            subtitleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            subtitleLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
            
            didUpdateConstraints = true
        }
        super.updateConstraints() // required
    }
}
