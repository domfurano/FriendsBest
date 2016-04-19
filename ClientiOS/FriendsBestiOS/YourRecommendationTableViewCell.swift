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
    
    private var containerView: UIView = UIView.newAutoLayoutView()
    
    private var tagsLabel: UILabel = UILabel.newAutoLayoutView()
    private var titleLabel: UILabel = UILabel.newAutoLayoutView()
    private var subtitleLabel: UILabel = UILabel.newAutoLayoutView()
    private var commentsLabel: UILabel = UILabel.newAutoLayoutView()
    
    private var tagsLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 14.0)!
    private var titleLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 22.0)!
    private var subtitleLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 15.0)!
    private var commentsLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 16.0)!

    
    convenience init(recommendation: Recommendation) {
        self.init()
        self.recommendation = recommendation

        selectionStyle = .None
        
        setTagsAttributedText(recommendation.tags!)
        titleLabel.text = recommendation.detail
        subtitleLabel.text = "HIYEeeeee!"
        commentsLabel.text = recommendation.comment
        
//        backgroundColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.layer.borderColor = UIColor.colorFromHex(0xE4E6E8).CGColor
        containerView.layer.borderWidth = 1.0
        containerView.layer.shadowColor = UIColor.colorFromHex(0xB8BBBF).CGColor
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        containerView.layer.shadowRadius = 1.0
        containerView.layer.shadowOpacity = 0.5
        
        tagsLabel.lineBreakMode = .ByTruncatingTail
        tagsLabel.numberOfLines = 1
        tagsLabel.textColor = UIColor.whiteColor()
        tagsLabel.font = tagsLabelFont
        tagsLabel.backgroundColor = UIColor.clearColor()
        
        titleLabel.lineBreakMode = .ByTruncatingTail
        titleLabel.numberOfLines = 1
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = titleLabelFont
        
        subtitleLabel.lineBreakMode = .ByTruncatingTail
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textColor = UIColor.darkGrayColor()
        subtitleLabel.font = subtitleLabelFont
        
        commentsLabel.lineBreakMode = .ByTruncatingTail
        commentsLabel.numberOfLines = 0
        commentsLabel.textColor = UIColor.blackColor()
        commentsLabel.font = commentsLabelFont
        
        
//        contentView.addSubview(tagsLabel)
        containerView.addSubview(titleLabel)
//        contentView.addSubview(subtitleLabel)
        containerView.addSubview(commentsLabel)
        contentView.addSubview(containerView)
    }
    
    private var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired,  forConstraints: {
//                self.contentView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//                self.tagsLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.titleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//                self.subtitleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.commentsLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.containerView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            })
            
            
            let horizontalInsets: CGFloat = 15.0
            let verticalInsets: CGFloat = 10.0
//
//            contentView.translatesAutoresizingMaskIntoConstraints = false
//            contentView.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
//            contentView.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
//            contentView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
//            contentView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
            
            
            containerView.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
            containerView.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            containerView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            containerView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
            
            titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
            titleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            titleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            
//            subtitleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 4.0, relation: .GreaterThanOrEqual)
//            subtitleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
//            subtitleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            
            commentsLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 4.0, relation: .GreaterThanOrEqual)
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






















































