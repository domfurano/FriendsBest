//
//  QueryHistoryTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/5/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import UIKit


class QueryHistoryTableViewCell: UITableViewCell {
    
    var tags: [String] = []
    var tagLabels: [UILabel] = []
    var new: Bool?
    
    var background: UIView = UIView()
    
    convenience init(tags: [String], style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        self.tags = tags
        selectionStyle = .None // No distinct style when selected
        backgroundColor = UIColor.clearColor()
        
        background.backgroundColor = UIColor.whiteColor()
        background.layer.cornerRadius = 2.0
        background.layer.shadowOpacity = 0.33
        background.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        background.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(background)
        
        for tag in tags {
            let label: UILabel = CommonUI.tagLabel(tag)
            tagLabels.append(label)
            contentView.addSubview(label)
        }
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
        
        var prevLabel: UILabel? = nil
        
        for label in tagLabels {
            
            addConstraint(
                NSLayoutConstraint(
                    item: label,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: background,
                    attribute: .Height,
                    multiplier: 0.66,
                    constant: 0.0
                )
            )
            
            addConstraint(
                NSLayoutConstraint(
                    item: label,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: background,
                    attribute: .CenterY,
                    multiplier: 1.0,
                    constant: 0.0
                )
            )
            
            if prevLabel == nil {
                addConstraint(
                    NSLayoutConstraint(
                        item: label,
                        attribute: .Left,
                        relatedBy: .Equal,
                        toItem: background,
                        attribute: .Left,
                        multiplier: 1.2,
                        constant: 0.0
                    )
                )
            } else {
                addConstraint(
                    NSLayoutConstraint(
                        item: label,
                        attribute: .Left,
                        relatedBy: .Equal,
                        toItem: prevLabel,
                        attribute: .Right,
                        multiplier: 1.1,
                        constant: 0.0
                    )
                )
            }
            
            prevLabel = label
        }
    }
}

































