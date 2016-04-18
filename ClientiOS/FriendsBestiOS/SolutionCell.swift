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
    
    var SOLUTION: Solution!
    
    var background: UIView = UIView.newAutoLayoutView()
    var detailLabel: UILabel = UILabel.newAutoLayoutView()
    
    convenience init(solution: Solution) {
        self.init()
        
        self.SOLUTION = solution
        
        selectionStyle = .None // No distinct style when selected
        backgroundColor = UIColor.clearColor()
        
        background.backgroundColor = UIColor.colorFromHex(0xDEDEDE)
        background.layer.cornerRadius = 2.0
        background.layer.shadowOpacity = 0.33
        background.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)

        
        if SOLUTION.type == .place {
            detailLabel.text = SOLUTION.placeName
        } else {
            detailLabel.text = SOLUTION.detail
        }
        
        detailLabel.font = UIFont(name: "Proxima Nova Cond", size: 18.0)!

        background.addSubview(detailLabel)
        contentView.addSubview(background)

    }
    
    var didUpdateContraints: Bool = false
    override func updateConstraints() {
        super.updateConstraints()
        
        if !didUpdateContraints {
            
            let horizontalInsets: CGFloat = 15.0
            let verticalInsets: CGFloat = 12.0
            
            let constraints: ALConstraintsBlock = {
                self.background.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.detailLabel.autoSetContentCompressionResistancePriorityForAxis(.Horizontal)
            }
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: constraints)
            
            background.autoPinEdgeToSuperviewEdge(.Top, withInset: 5.0)
            background.autoPinEdgeToSuperviewEdge(.Leading, withInset: 15.0)
            background.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 15.0)
            background.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5.0)
            
            detailLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
            detailLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            detailLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            detailLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: background,
//                    attribute: .CenterX,
//                    relatedBy: .Equal,
//                    toItem: self,
//                    attribute: .CenterX,
//                    multiplier: 1.0,
//                    constant: 0.0
//                )
//            )
//            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: background,
//                    attribute: .CenterY,
//                    relatedBy: .Equal,
//                    toItem: self,
//                    attribute: .CenterY,
//                    multiplier: 1.0,
//                    constant: 0.0
//                )
//            )
//            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: background,
//                    attribute: .Width,
//                    relatedBy: .Equal,
//                    toItem: self,
//                    attribute: .Width,
//                    multiplier: 0.9,
//                    constant: 0.0
//                )
//            )
//            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: background,
//                    attribute: .Height,
//                    relatedBy: .Equal,
//                    toItem: self,
//                    attribute: .Height,
//                    multiplier: 0.8,
//                    constant: 0.0
//                )
//            )
//            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: detailLabel,
//                    attribute: .Left,
//                    relatedBy: .Equal,
//                    toItem: background,
//                    attribute: .Left,
//                    multiplier: 1.0,
//                    constant: 8.0
//                )
//            )
//            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: detailLabel,
//                    attribute: .Right,
//                    relatedBy: .Equal,
//                    toItem: background,
//                    attribute: .Right,
//                    multiplier: 1.0,
//                    constant: -8.0
//                )
//            )
//            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: detailLabel,
//                    attribute: .CenterY,
//                    relatedBy: .Equal,
//                    toItem: background,
//                    attribute: .CenterY,
//                    multiplier: 1.0,
//                    constant: 0.0
//                )
//            )
        }
    }
}
