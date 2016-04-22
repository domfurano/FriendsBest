//
//  SolutionDetailTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/4/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import PureLayout

// TODO: Cell isn't displaying all text

class SolutionDetailTableViewCell: UITableViewCell {
    var RECOMMENDATION: FriendRecommendation!
    
    var friendImageView: UIImageView = UIImageView.newAutoLayoutView()
    var nameLabel: UILabel = UILabel.newAutoLayoutView()
    var commentLabel: UILabel = UILabel.newAutoLayoutView()
    
    convenience init(recommendation: FriendRecommendation) {
        self.init()
        RECOMMENDATION = recommendation
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
        
        contentView.backgroundColor = UIColor.whiteColor()
        
        if RECOMMENDATION.friend != nil {
            friendImageView = RECOMMENDATION.friend!.squarePicture
            
            nameLabel.text = RECOMMENDATION.friend!.name
            nameLabel.font = UIFont(name: "ProximaNovaCond-Bold", size: 20.0)
            nameLabel.lineBreakMode = .ByTruncatingTail
            nameLabel.numberOfLines = 1
            nameLabel.textAlignment = .Left
            nameLabel.textColor = UIColor.blackColor()
            
            contentView.addSubview(friendImageView)
            contentView.addSubview(nameLabel)
        }
        
        commentLabel.text = RECOMMENDATION.comment
        commentLabel.font = UIFont(name: "Proxima Nova Cond", size: 16.0)
        commentLabel.lineBreakMode = .ByTruncatingTail
        commentLabel.numberOfLines = 0
        commentLabel.textAlignment = .Left
        commentLabel.textColor = UIColor.darkGrayColor()
        
        contentView.addSubview(commentLabel)
    }
    
    func setupCellForDisplay(recommendation: FriendRecommendation) {
        
    }
    
    var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
            let horizontalInsets: CGFloat = 15.0
            let verticalInsets: CGFloat = 10.0
                        
            if self.RECOMMENDATION.friend != nil {
                let constraints: ALConstraintsBlock = {
                    self.nameLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                    self.friendImageView.autoSetContentCompressionResistancePriorityForAxis(.Horizontal)
                    self.friendImageView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                    self.commentLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                }
                NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: constraints)
                
                friendImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
                friendImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
                friendImageView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets, relation: .GreaterThanOrEqual)
                
                nameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
                addConstraint(
                    NSLayoutConstraint(
                        item: nameLabel,
                        attribute: .Trailing,
                        relatedBy: .LessThanOrEqual,
                        toItem: contentView,
                        attribute: .Trailing,
                        multiplier: 1.0,
                        constant: 0.0))
                addConstraint(
                    NSLayoutConstraint(
                        item: nameLabel,
                        attribute: .Leading,
                        relatedBy: .Equal,
                        toItem: friendImageView,
                        attribute: .Trailing,
                        multiplier: 1.0,
                        constant: horizontalInsets))
                
                commentLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: nameLabel, withOffset: verticalInsets, relation: .GreaterThanOrEqual)
                addConstraint(
                    NSLayoutConstraint(
                        item: commentLabel,
                        attribute: .Trailing,
                        relatedBy: .LessThanOrEqual,
                        toItem: contentView,
                        attribute: .Trailing,
                        multiplier: 1.0,
                        constant: 0.0))
                addConstraint(
                    NSLayoutConstraint(
                        item: commentLabel,
                        attribute: .Leading,
                        relatedBy: .Equal,
                        toItem: friendImageView,
                        attribute: .Trailing,
                        multiplier: 1.0,
                        constant: horizontalInsets))
                commentLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
            } else {
                let constraints: ALConstraintsBlock = {
                    self.commentLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                }
                NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: constraints)
                
                commentLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
                commentLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
                commentLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
                commentLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
                
            }
            
            didUpdateConstraints = true
        }
        
        super.updateConstraints() // required
    }
    
}
