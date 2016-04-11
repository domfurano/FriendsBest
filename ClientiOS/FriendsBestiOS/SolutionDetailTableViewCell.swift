//
//  SolutionDetailTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/4/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import PureLayout

class SolutionDetailTableViewCell: UITableViewCell {
    
    
    //            self.textLabel
    //            self.detailTextLabel
    //            self.imageView
    
    let kLabelHorizontalInsets: CGFloat = 15.0
    let kLabelVerticalInsets: CGFloat = 10.0
    
    var nameLabel: UILabel = UILabel()
    var commentLabel: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    func setupViews() {
        
//        nameLabel.lineBreakMode = .ByTruncatingTail
//        nameLabel.numberOfLines = 1
//        nameLabel.textAlignment = .Left
//        nameLabel.textColor = UIColor.blackColor()
//        nameLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.1) // light blue
//        
//        commentLabel.lineBreakMode = .ByTruncatingTail
//        commentLabel.numberOfLines = 0
//        commentLabel.textAlignment = .Left
//        commentLabel.textColor = UIColor.darkGrayColor()
//        commentLabel.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1) // light red
//        
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        commentLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        contentView.addSubview(nameLabel)
//        contentView.addSubview(commentLabel)
        
        textLabel!.lineBreakMode = .ByTruncatingTail
        textLabel!.numberOfLines = 1
        textLabel!.textAlignment = .Left
        textLabel!.textColor = UIColor.blackColor()
        textLabel!.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.1) // light blue
        
        detailTextLabel!.lineBreakMode = .ByTruncatingTail
        detailTextLabel!.numberOfLines = 0
        detailTextLabel!.textAlignment = .Left
        detailTextLabel!.textColor = UIColor.darkGrayColor()
        detailTextLabel!.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1) // light red
        
        textLabel!.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel!.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textLabel!)
        contentView.addSubview(detailTextLabel!)
        
    }
    
    var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
//            let constraints: ALConstraintsBlock = {
//                self.nameLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//                self.commentLabel.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
//            }
//            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: constraints)
//            
//            nameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: kLabelVerticalInsets)
//            nameLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: kLabelHorizontalInsets)
//            nameLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: kLabelHorizontalInsets)
//            
//            commentLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: nameLabel, withOffset: 10.0, relation: .GreaterThanOrEqual)
//            commentLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: kLabelHorizontalInsets)
//            commentLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: kLabelHorizontalInsets)
//            commentLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: kLabelVerticalInsets)
            let constraints: ALConstraintsBlock = {
                self.textLabel!.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                self.detailTextLabel!.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
            }
            NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: constraints)
            
            textLabel!.autoPinEdgeToSuperviewEdge(.Top, withInset: kLabelVerticalInsets)
//            textLabel!.autoPinEdgeToSuperviewEdge(.Leading, withInset: kLabelHorizontalInsets)
//            textLabel!.autoPinEdgeToSuperviewEdge(.Trailing, withInset: kLabelHorizontalInsets)
            
            detailTextLabel!.autoPinEdge(.Top, toEdge: .Bottom, ofView: textLabel!, withOffset: 10.0, relation: .GreaterThanOrEqual)
//            detailTextLabel!.autoPinEdgeToSuperviewEdge(.Leading, withInset: kLabelHorizontalInsets)
//            detailTextLabel!.autoPinEdgeToSuperviewEdge(.Trailing, withInset: kLabelHorizontalInsets)
            detailTextLabel!.autoPinEdgeToSuperviewEdge(.Bottom, withInset: kLabelVerticalInsets)
            
            
            didUpdateConstraints = true
        }
        
        super.updateConstraints() // required
    }
    
}
