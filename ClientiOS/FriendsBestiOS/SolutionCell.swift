//
//  SolutionCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/7/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class SolutionCell: UITableViewCell {
    
    var background: UIView = UIView()
    var detailLabel: UILabel = UILabel()
    
    convenience init(detail: String, style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None // No distinct style when selected
        backgroundColor = UIColor.clearColor()
        
        background.backgroundColor = UIColor.whiteColor()
        background.layer.cornerRadius = 2.0
        background.layer.shadowOpacity = 0.33
        background.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        background.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(background)
        
        detailLabel.text = detail
        detailLabel.font = UIFont(name: "Avenir", size: 22.0)!
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(detailLabel)

    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addConstraint(
            NSLayoutConstraint(
                item: background,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0
            )
        )
        
        addConstraint(
            NSLayoutConstraint(
                item: background,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0.0
            )
        )
        
        addConstraint(
            NSLayoutConstraint(
                item: background,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Width,
                multiplier: 0.8,
                constant: 0.0
            )
        )
        
        addConstraint(
            NSLayoutConstraint(
                item: background,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Height,
                multiplier: 0.8,
                constant: 0.0
            )
        )
        
        addConstraint(
            NSLayoutConstraint(
                item: detailLabel,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: background,
                attribute: .Left,
                multiplier: 1.3,
                constant: 0.0
            )
        )
        
        addConstraint(
            NSLayoutConstraint(
                item: detailLabel,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: background,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0.0
            )
        )
    }
}
