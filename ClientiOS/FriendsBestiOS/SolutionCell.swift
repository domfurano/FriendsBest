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
    var detailLabel: UILabel = UILabel.newAutoLayoutView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None // No distinct style when selected
        backgroundColor = UIColor.clearColor()
        
        background.backgroundColor = UIColor.colorFromHex(0xDEDEDE)
        background.layer.cornerRadius = 2.0
        background.layer.shadowOpacity = 0.33
        background.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)

        detailLabel.font = UIFont(name: "Proxima Nova Cond", size: 18.0)!
        
        contentView.addSubview(background)
        contentView.addSubview(detailLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupForViewing(title: String) {
        detailLabel.text = title
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    var didUpdateContraints: Bool = false
    override func updateConstraints() {
        if !didUpdateContraints {
            let constraints: ALConstraintsBlock = {
                self.background.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.detailLabel.autoSetContentCompressionResistancePriorityForAxis(.Horizontal)
            }
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: constraints)
            
            let backgroundInset: CGFloat = 8.0
            background.autoPinEdgeToSuperviewEdge(.Top, withInset: backgroundInset)
            background.autoPinEdgeToSuperviewEdge(.Leading, withInset: backgroundInset)
            background.autoPinEdgeToSuperviewEdge(.Trailing, withInset: backgroundInset)
            background.autoPinEdgeToSuperviewEdge(.Bottom, withInset: backgroundInset)
            
            let detailVerticalInset: CGFloat = 20.0
            let detailHorizontalInset: CGFloat = 16.0
            detailLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: detailVerticalInset)
            detailLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: detailHorizontalInset)
            detailLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: detailHorizontalInset)
            detailLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: detailVerticalInset)
        }
        super.updateConstraints()
    }
}
