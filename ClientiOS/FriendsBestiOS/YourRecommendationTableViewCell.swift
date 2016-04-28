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
    
    private var containerView: UIView = UIView.newAutoLayoutView()
    
    private var tagsLabel: UILabel = UILabel.newAutoLayoutView()
    private var titleLabel: UILabel = UILabel.newAutoLayoutView()
    private var subtitleLabel: UILabel = UILabel.newAutoLayoutView()
    private var commentsLabel: UILabel = UILabel.newAutoLayoutView()
    
    private var tagsLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 14.0)!
    private var titleLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 18.0)!
    private var subtitleLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 12.0)!
    private var commentsLabelFont: UIFont = UIFont(name: "Proxima Nova Cond", size: 16.0)!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        backgroundColor = UIColor.clearColor()
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
        
        titleLabel.lineBreakMode = .ByTruncatingTail
        titleLabel.numberOfLines = 1
        titleLabel.textColor = UIColor.blackColor()
        
        subtitleLabel.lineBreakMode = .ByTruncatingTail
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = UIColor.darkGrayColor()
        
        commentsLabel.lineBreakMode = .ByTruncatingTail
        commentsLabel.numberOfLines = 0
        commentsLabel.textColor = UIColor.blackColor()
        
        updateFonts()
        
        contentView.addSubview(containerView)
        contentView.addSubview(tagsLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(commentsLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupForViewing(tagString: String, title: String, subtitle: String, comments: String) {
        setTagsAttributedText(tagString.componentsSeparatedByString(" "))
        titleLabel.text = title
        subtitleLabel.text = subtitle
        commentsLabel.text = comments
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    private var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        contentView.bounds = CGRect(x: 0.0, y: 0.0, width: 99999.0, height: 99999.0)
        //        if !didUpdateConstraints {
        
        NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired,  forConstraints: {
            self.tagsLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            self.titleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            self.subtitleLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            self.commentsLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            self.containerView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
        })
        
        tagsLabel.autoPinEdge(.Left, toEdge: .Left, ofView: containerView)
        tagsLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: containerView)
        
        let containerViewInset: CGFloat = 8.0
        containerView.autoPinEdgeToSuperviewEdge(.Top, withInset: 32.0)
        containerView.autoPinEdgeToSuperviewEdge(.Leading, withInset: containerViewInset)
        containerView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: containerViewInset)
        containerView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: containerViewInset)
        
        
        let horizontalInsets: CGFloat = 16.0
        let verticalInsets: CGFloat = 16.0
        let spacingOffset: CGFloat = 2.0
        
        titleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 36.0)
        titleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
        titleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
        
        subtitleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: spacingOffset, relation: .GreaterThanOrEqual)
        subtitleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
        subtitleLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
        
        commentsLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: subtitleLabel, withOffset: spacingOffset, relation: .GreaterThanOrEqual)
        commentsLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
        commentsLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
        commentsLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
        
        
        didUpdateConstraints = true
        
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
    
    func updateFonts() {
        tagsLabel.font = tagsLabelFont
        titleLabel.font = titleLabelFont
        subtitleLabel.font = subtitleLabelFont
        commentsLabel.font = commentsLabelFont
    }
}






















































