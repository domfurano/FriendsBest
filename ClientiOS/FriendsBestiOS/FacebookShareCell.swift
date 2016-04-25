//
//  FacebookShareCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/24/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKShareKit

class FacebookShareCell: UITableViewCell {
    var background: UIView = UIView.newAutoLayoutView()
    var titleLabel: UILabel = UILabel.newAutoLayoutView()
    var subtitleLabel: UILabel = UILabel.newAutoLayoutView()
    var facebookSHareButton: FBSDKShareButton = FBSDKShareButton.newAutoLayoutView()
    
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
        
        background.backgroundColor = UIColor.colorFromHex(0x415DAE)
        
        titleLabel.font = UIFont(name: "ProximaNovaCond-Bold", size: 16.0)!
        titleLabel.text = "Want more results?"
        titleLabel.textColor = UIColor.whiteColor()
        
        subtitleLabel.font = UIFont(name: "Proxima Nova Cond", size: 12.0)!
        subtitleLabel.textColor = UIColor.whiteColor()
        subtitleLabel.text = "Click to post this search to Facebook."
        
        contentView.addSubview(background)
        background.addSubview(titleLabel)
        background.addSubview(subtitleLabel)
        background.addSubview(facebookSHareButton)
    }
    
    func setupForViewing(tagString: String) {
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://www.facebook.net/")
        content.contentTitle = "I'm searching for '\(tagString)'"
        content.contentDescription = "Please join me on FriendsBest.net and share your recommendation."
        facebookSHareButton.shareContent = content
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
            titleLabel.autoPinEdge(.Trailing, toEdge: .Leading, ofView: facebookSHareButton, withOffset: 9.0, relation: .LessThanOrEqual)
            
            subtitleLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: titleLabel, withOffset: 0.2, relation: .GreaterThanOrEqual)
            subtitleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: detailHorizontalInset)
            subtitleLabel.autoPinEdge(.Trailing, toEdge: .Leading, ofView: facebookSHareButton, withOffset: 9.0, relation: .LessThanOrEqual)
            subtitleLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: detailVerticalInset)
            
            facebookSHareButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: detailHorizontalInset)
            facebookSHareButton.autoAlignAxisToSuperviewAxis(.Horizontal)
        }
        super.updateConstraints()
    }
}
