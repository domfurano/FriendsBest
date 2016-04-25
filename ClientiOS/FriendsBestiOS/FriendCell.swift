//
//  SolutionDetailTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/4/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import PureLayout


class FriendCell: UITableViewCell {
    var containerView: UIView = UIView.newAutoLayoutView()
    var friendImageView: UIImageView = UIImageView.newAutoLayoutView()
    var nameLabel: UILabel = UILabel.newAutoLayoutView()
    var muteButton: UIButton = UIButton.newAutoLayoutView()
    
    var muteButtonSelectedDelegate: (() -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        
        selectionStyle = .None
        
        contentView.backgroundColor = UIColor.clearColor()
        
        containerView.backgroundColor = UIColor.whiteColor()
        
        nameLabel.font = UIFont(name: "ProximaNovaCond-Bold", size: 16.0)
        nameLabel.lineBreakMode = .ByTruncatingTail
        nameLabel.numberOfLines = 1
        nameLabel.textAlignment = .Left
        nameLabel.textColor = UIColor.blackColor()
        
        muteButton.addTarget(self, action: #selector(FriendCell.mutingButtonSelected), forControlEvents: .TouchUpInside)
        
        contentView.addSubview(containerView)
        contentView.addSubview(friendImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(muteButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mutingButtonSelected() {
        muteButtonSelectedDelegate?()
    }
    
    func setupCellForDisplay(friendImage: UIImage, name: String, muteIcon: UIImage) {
        friendImageView.image = friendImage
        nameLabel.text = name
        muteButton.setImage(muteIcon, forState: .Normal)
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
            let horizontalInsets: CGFloat = 15.0
            let verticalInsets: CGFloat = 10.0
            
            let constraints: ALConstraintsBlock = {
                self.nameLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.friendImageView.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.friendImageView.autoSetContentCompressionResistancePriorityForAxis(.Horizontal)
                self.muteButton.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.muteButton.autoSetContentCompressionResistancePriorityForAxis(.Horizontal)
            }
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: constraints)
            
            containerView.autoPinEdgeToSuperviewEdge(.Top, withInset: 5.0)
            containerView.autoPinEdgeToSuperviewEdge(.Left, withInset: 7.5)
            containerView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 5.0)
            containerView.autoPinEdgeToSuperviewEdge(.Right, withInset: 7.5)
            
            friendImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
            friendImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
            friendImageView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
            
            nameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
            nameLabel.autoPinEdge(.Leading, toEdge: .Trailing, ofView: friendImageView, withOffset: horizontalInsets)
            nameLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)

            addConstraint(NSLayoutConstraint(
                item: nameLabel,
                attribute: .Trailing,
                relatedBy: .LessThanOrEqual,
                toItem: muteButton,
                attribute: .Leading,
                multiplier: 1.0,
                constant: horizontalInsets))

            muteButton.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
            muteButton.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            didUpdateConstraints = true
        }
        
        super.updateConstraints() // required
    }
    
}
