//
//  YourRecommendationTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/12/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import PureLayout

class YourRecommendationTableViewCell: UITableViewCell {
    
    var recommendation: Recommendation!
    
    private var tagsLabel: UILabel = UILabel.newAutoLayoutView()
    private var titleLabel: UILabel = UILabel.newAutoLayoutView()
    private var commentsLabel: UILabel = UILabel.newAutoLayoutView()
    
    private var tagsLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 14.0)!
    private var titleLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 22.0)!
    private var commentsLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 16.0)!
    
    private let horizontalInsets: CGFloat = 15.0
    private let verticalInsets: CGFloat = 10.0
    
    convenience init(recommendation: Recommendation) {
        self.init()
        self.recommendation = recommendation

        selectionStyle = .None
        
        if recommendation.type != .text {
            userInteractionEnabled = true
        } else {
            userInteractionEnabled = false
        }
        
        setTagsAttributedText(recommendation.tags!)
        titleLabel.text = recommendation.detail
        commentsLabel.text = recommendation.comment
        
        tagsLabel.lineBreakMode = .ByTruncatingTail
        tagsLabel.numberOfLines = 1
        tagsLabel.textColor = UIColor.whiteColor()
        tagsLabel.font = tagsLabelFont
        
        
        titleLabel.lineBreakMode = .ByTruncatingTail
        titleLabel.numberOfLines = 1
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = titleLabelFont
        
        
        commentsLabel.lineBreakMode = .ByTruncatingTail
        commentsLabel.numberOfLines = 0
        commentsLabel.textColor = UIColor.darkGrayColor()
        commentsLabel.font = commentsLabelFont
        
        
        contentView.addSubview(tagsLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(commentsLabel)
    }
    
    private var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired,  forConstraints: {
                self.titleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.titleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.commentsLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            })
            
            tagsLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
            tagsLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            tagsLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            
            titleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: tagsLabel, withOffset: 8.0, relation: .GreaterThanOrEqual)
            titleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            titleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            
            commentsLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 8.0, relation: .GreaterThanOrEqual)
            commentsLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            commentsLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            commentsLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
            
            didUpdateConstraints = true
        }
        
        super.updateConstraints() // required
    }
    
    private func setTagsAttributedText(tags: [String]) {
        tagsLabel.attributedText = attributedStringForTags(tags)
    }
    
    private func attributedStringForTags(tagArray: [String]) -> NSAttributedString {
        let returnString: NSMutableAttributedString = NSMutableAttributedString()
        
//        let tagBGColor = UIColor.colorFromHex(0x8E969B)
        let attributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSBackgroundColorAttributeName: UIColor.colorFromHex(0x83969b),
            NSFontAttributeName: tagsLabelFont,
        ]
        let space = NSAttributedString(string: "  ")

        for tag in tagArray {
            returnString.appendAttributedString(NSAttributedString(string: " \(tag) ", attributes: attributes))
            returnString.appendAttributedString(space)
        }
        
        return returnString
    }
}






















































