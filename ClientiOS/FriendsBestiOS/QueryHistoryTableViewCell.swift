//
//  QueryHistoryTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/13/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import PureLayout

class QueryHistoryTableViewCell: UITableViewCell {
    var QUERY: Query!
    var contentContainer: UIView!
    var tagsLabel: UILabel!
    
    convenience init(query: Query) {
        self.init()
        QUERY = query

        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        
        contentContainer = UIView.newAutoLayoutView()
        contentContainer.layer.borderColor = UIColor.colorFromHex(0xE4E6E7).CGColor
        contentContainer.layer.borderWidth = 1.0
        contentContainer.backgroundColor = UIColor.whiteColor()
        contentContainer.alpha = 1.0
        
        contentContainer.layer.shadowColor = UIColor.colorFromHex(0xE4E6E7).CGColor
        contentContainer.layer.shadowRadius = 1.0
        contentContainer.layer.shadowOpacity = 0.33
        contentContainer.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)

        tagsLabel = UILabel.newAutoLayoutView()
        tagsLabel.attributedText = attributedStringForTags(QUERY.tagString.componentsSeparatedByString(" "))
        tagsLabel.lineBreakMode = .ByTruncatingTail
        tagsLabel.numberOfLines = 0

        contentView.addSubview(contentContainer)
        contentContainer.addSubview(tagsLabel)
    }
    
    private var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired,  forConstraints: {
                self.contentContainer.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.tagsLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            })
            
            let ccInsetVertical: CGFloat = 4.0
            let ccInsetHorizontal: CGFloat = 16.0
            contentContainer.autoPinEdgeToSuperviewEdge(.Top, withInset: ccInsetVertical)
            contentContainer.autoPinEdgeToSuperviewEdge(.Leading, withInset: ccInsetHorizontal)
            contentContainer.autoPinEdgeToSuperviewEdge(.Trailing, withInset: ccInsetHorizontal)
            contentContainer.autoPinEdgeToSuperviewEdge(.Bottom, withInset: ccInsetVertical)
            
            let tlInset: CGFloat = 12.0
            tagsLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: tlInset)
            tagsLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: tlInset)
            tagsLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: tlInset)
            tagsLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: tlInset)
            
            didUpdateConstraints = true
        }
        
        super.updateConstraints() // required
    }
    
    private func attributedStringForTags(tagArray: [String]) -> NSAttributedString {
        let returnString: NSMutableAttributedString = NSMutableAttributedString()
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 30
        
        let attributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSBackgroundColorAttributeName: UIColor.colorFromHex(0xEDEDED),
            NSFontAttributeName: UIFont(name: "Proxima Nova Cond", size: 16.0)!
            ]
        
        let space = NSAttributedString(string: "  ")
        
        for tag in tagArray {
            returnString.appendAttributedString(NSAttributedString(string: "  \(tag)  ", attributes: attributes))
            returnString.appendAttributedString(space)
        }
        
        return returnString
    }
    
}
