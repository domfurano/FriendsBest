
//
//  SolutionDetailHeaderTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/16/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import PureLayout
import GoogleMaps

class SolutionDetailHeaderTableViewCell: UITableViewCell {
    var RECOMMENDATION: Recommendation!
    
    /* text type */
    var textTitle: UILabel?
    
    /* place type */
    var placeTitle: UILabel?
    var placeAddress: UILabel?
    //    ...
    
    /* url type */
    var urlTitle: UILabel?
    
    convenience init(recommendation: Recommendation) {
        self.init()
        RECOMMENDATION = recommendation
        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = false
        
        contentView.backgroundColor = CommonUI.sdNavbarBgColor
        
        switch RECOMMENDATION.type {
        case .text:
            textTitle = UILabel.newAutoLayoutView()
            textTitle?.numberOfLines = 0
            textTitle?.text = RECOMMENDATION.detail
            textTitle?.font = UIFont(name: "ProximaNovaCond-Bold", size: 20.0)
            textTitle?.textColor = UIColor.whiteColor()
            contentView.addSubview(textTitle!)
            break
        case .place:
            placeTitle = UILabel.newAutoLayoutView()
            placeTitle?.text = RECOMMENDATION.placeName
            placeTitle?.numberOfLines = 0
            placeTitle?.font = UIFont(name: "ProximaNovaCond-Bold", size: 20.0)
            placeTitle?.textColor = UIColor.whiteColor()
            placeAddress = UILabel.newAutoLayoutView()
            placeAddress?.text = RECOMMENDATION.placeAddress
            placeAddress?.font = UIFont(name: "Proxima Nova Cond", size: 18.0)
            placeAddress?.numberOfLines = 0
            placeAddress?.textColor = UIColor.whiteColor()
            contentView.addSubview(placeTitle!)
            contentView.addSubview(placeAddress!)
            break
        case .url:
            urlTitle = UILabel.newAutoLayoutView()
            urlTitle?.numberOfLines = 0
            urlTitle?.text = RECOMMENDATION.detail
            urlTitle?.font = UIFont(name: "ProximaNovaCond-Bold", size: 20.0)
            urlTitle?.textColor = UIColor.whiteColor()
            contentView.addSubview(urlTitle!)
            break
        }
        
    }
    
    var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
            let horizontalInsets: CGFloat = 15.0
            let verticalInsets: CGFloat = 10.0
            
            switch RECOMMENDATION.type {
            case .text:
                NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: {
                    self.textTitle?.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                })
                textTitle?.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
                textTitle?.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
                textTitle?.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
                textTitle?.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
                break
            case .place:
                NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: {
                    self.placeTitle?.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                    self.placeAddress?.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                })
                placeTitle?.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
                placeTitle?.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
                placeTitle?.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
                placeAddress?.autoPinEdge(.Top, toEdge: .Bottom, ofView: placeTitle!, withOffset: verticalInsets, relation: .GreaterThanOrEqual)
                placeAddress?.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
                placeAddress?.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
                placeAddress?.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
                break
            case .url:
                NSLayoutConstraint.autoSetPriority(UILayoutPriorityRequired, forConstraints: {
                    self.urlTitle?.autoSetContentCompressionResistancePriorityForAxis(.Vertical)
                })
                urlTitle?.autoPinEdgeToSuperviewEdge(.Top, withInset: verticalInsets)
                urlTitle?.autoPinEdgeToSuperviewEdge(.Leading, withInset: horizontalInsets)
                urlTitle?.autoPinEdgeToSuperviewEdge(.Trailing, withInset: horizontalInsets)
                urlTitle?.autoPinEdgeToSuperviewEdge(.Bottom, withInset: verticalInsets)
                break
            }
            
            didUpdateConstraints = true
        }
        
        super.updateConstraints() // required
    }
}
