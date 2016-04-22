////
////  SolutionsCell.swift
////  FriendsBest
////
////  Created by Dominic Furano on 3/7/16.
////  Copyright © 2016 Dominic Furano. All rights reserved.
////
//
//import UIKit
//
//class SolutionsTagCell: UITableViewCell {
//    
//    var tags: [String] = []
//    var tagLabels: [UILabel] = []
//    
//    
//    convenience init(tags: [String], style: UITableViewCellStyle, reuseIdentifier: String?) {
//        self.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.tags = tags
//        selectionStyle = .None
//        backgroundColor = UIColor.clearColor()
//        
//        for tag in tags {
//            let label: UILabel = CommonUI.tagLabel(tag)
//            tagLabels.append(label)
//            contentView.addSubview(label)
//        }
//        
//    }
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        var prevLabel: UILabel? = nil
//        
//        for label in tagLabels {
//            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: label,
//                    attribute: .Height,
//                    relatedBy: .Equal,
//                    toItem: self,
//                    attribute: .Height,
//                    multiplier: 0.66,
//                    constant: 0.0
//                )
//            )
//            
//            addConstraint(
//                NSLayoutConstraint(
//                    item: label,
//                    attribute: .CenterY,
//                    relatedBy: .Equal,
//                    toItem: self,
//                    attribute: .CenterY,
//                    multiplier: 1.0,
//                    constant: 0.0
//                )
//            )
//            
//            if prevLabel == nil {
//                addConstraint(
//                    NSLayoutConstraint(
//                        item: label,
//                        attribute: .Left,
//                        relatedBy: .Equal,
//                        toItem: self,
//                        attribute: .Left,
//                        multiplier: 1.0,
//                        constant: 20.0
//                    )
//                )
//            } else {
//                addConstraint(
//                    NSLayoutConstraint(
//                        item: label,
//                        attribute: .Left,
//                        relatedBy: .Equal,
//                        toItem: prevLabel,
//                        attribute: .Right,
//                        multiplier: 1.1,
//                        constant: 0.0
//                    )
//                )
//            }
//            
//            prevLabel = label
//        }
//    }
//}
