//
//  NewRecommendationViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/26/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class NewRecommendationViewController: UIViewController, UITextFieldDelegate {
    
    let tagsLabel: UILabel = UILabel()
    let tagsField: UITextField = UITextField()
    
    let titleLabel: UILabel = UILabel()
    let titleField: UITextField = UITextField()
    
    let commentsLabel: UILabel = UILabel()
    let commentsField: UITextView = UITextView()
    
    
    override func loadView() {
        view = NewRecommendationView()
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
    }
    
    override func viewDidLoad() {
        styleControls()
        
        view.addSubview(tagsLabel)
        view.addSubview(tagsField)
        
        view.addSubview(titleLabel)
        view.addSubview(titleField)
        
        view.addSubview(commentsLabel)
        view.addSubview(commentsField)
        
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleField.translatesAutoresizingMaskIntoConstraints = false
        
        commentsLabel.translatesAutoresizingMaskIntoConstraints = false
        commentsField.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        title = "New Recommendation"
        edgesForExtendedLayout = UIRectEdge.None
        setToolbarItems()
    }
    
    private func styleControls() {
        tagsLabel.text = "Tags"
        tagsField.backgroundColor = UIColor.whiteColor()
        tagsField.borderStyle = UITextBorderStyle.RoundedRect
        
        titleLabel.text = "Title"
        titleField.backgroundColor = UIColor.whiteColor()
        titleField.borderStyle = UITextBorderStyle.RoundedRect
        
        commentsLabel.text = "Comments"
        commentsField.backgroundColor = UIColor.whiteColor()
        commentsField.editable = true
        commentsField.layer.borderWidth = 0.2
        commentsField.layer.cornerRadius = 5
    }
    
    /* Constraints */
    
    private func addConstraints() {
        view.addConstraint(
            NSLayoutConstraint(
                item: tagsLabel,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: tagsField,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: tagsField,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.8,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: tagsField,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: titleLabel,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: titleField,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: titleField,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.8,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: titleField,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: commentsLabel,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: commentsField,
                attribute: NSLayoutAttribute.Left,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: commentsField,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.8,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: commentsField,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: commentsField,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.5,
                constant: 0.0))
        
        let views: [String: UIView] = [
            "tagsLabel": tagsLabel,
            "tags" : tagsField,
            "titleLabel": titleLabel,
            "title" : titleField,
            "commentsLabel": commentsLabel,
            "comments" : commentsField
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-16-[tagsLabel]-[tags]-[titleLabel]-[title]-[commentsLabel]-[comments]",
            options: NSLayoutFormatOptions(), metrics: nil, views: views))
    }
    
    private func setToolbarItems() {
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("newRecommendationButtonPressed"))
        
        self.toolbarItems = [flexibleSpace, newRecommendationButton]
    }
    
}
