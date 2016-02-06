//
//  NewRecommendationViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/26/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class NewRecommendationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    let tagsLabel: UILabel = UILabel()
    let tagsField: UITextField = UITextField()
    
    let titleLabel: UILabel = UILabel()
    let titleField: UITextField = UITextField()
    
    let commentsLabel: UILabel = UILabel()
    let commentsField: UITextView = UITextView()
    
    let NRinputAccessoryView: NewRecommendationInputAccessoryView = NewRecommendationInputAccessoryView()
    
    var scrollView: UIScrollView {
        get {
            return self.view as! UIScrollView
        }
    }
    
    override func loadView() {
        self.view = NewRecommendationView()
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
    }
    
    override func viewDidLoad() {
        styleControls()
        
        tagsField.delegate = self
        titleField.delegate = self
        commentsField.delegate = self
        NRinputAccessoryView.recommendButton?.addTarget(
            self,
            action: "createNewRecommendationButtonPressed",
            forControlEvents: UIControlEvents.TouchUpInside
        )
        
        view.addSubview(tagsLabel)
        view.addSubview(tagsField)
        
        view.addSubview(titleLabel)
        view.addSubview(titleField)
        
        view.addSubview(commentsLabel)
        view.addSubview(commentsField)
        
//        view.addSubview(NRinputAccessoryView)
        
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleField.translatesAutoresizingMaskIntoConstraints = false
        
        commentsLabel.translatesAutoresizingMaskIntoConstraints = false
        commentsField.translatesAutoresizingMaskIntoConstraints = false
        
//        NRinputAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        title = "New Recommendation"
        edgesForExtendedLayout = UIRectEdge.None
        setToolbarItems()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == tagsField {
            titleField.becomeFirstResponder()
        } else if textField == titleField {
            commentsField.becomeFirstResponder()
        } else if textField == commentsField {
            commentsField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
//        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, textField.bound, <#T##right: CGFloat##CGFloat#>)
    }
    
    private func styleControls() {
        tagsLabel.text = "Tags"
        tagsField.backgroundColor = UIColor.whiteColor()
        tagsField.borderStyle = UITextBorderStyle.RoundedRect
        tagsField.returnKeyType = UIReturnKeyType.Next
        tagsField.keyboardAppearance = .Dark
        
        titleLabel.text = "Title"
        titleField.backgroundColor = UIColor.whiteColor()
        titleField.borderStyle = UITextBorderStyle.RoundedRect
        titleField.returnKeyType = UIReturnKeyType.Next
        titleField.keyboardAppearance = .Dark
        
        commentsLabel.text = "Comments"
        commentsField.backgroundColor = UIColor.whiteColor()
        commentsField.editable = true
        commentsField.layer.borderWidth = 0.2
        commentsField.layer.cornerRadius = 5
        commentsField.returnKeyType = .Default
        commentsField.keyboardAppearance = .Dark
        commentsField.inputAccessoryView = NRinputAccessoryView
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
        
//        view.addConstraint(
//            NSLayoutConstraint(
//                item: NRinputAccessoryView,
//                attribute: NSLayoutAttribute.Height,
//                relatedBy: NSLayoutRelation.Equal,
//                toItem: view,
//                attribute: NSLayoutAttribute.Height,
//                multiplier: 0.1,
//                constant: 0.0))
        
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
    
    func createNewRecommendationButtonPressed() {
        if let description = titleField.text, let tags = tagsField.text {
            let comments = commentsField.text == nil ? "" : commentsField.text!
            let tags = tags.characters.split{ $0 == " " }.map(String.init)
            NetworkDAO.instance.postNewRecommendtaion(description, comments: comments, recommendationTags: tags)
            navigationController?.popViewControllerAnimated(true)
        } else {
            // Show the user an error.
        }
    }
    
    private func setToolbarItems() {
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusIconWithSize(22)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 22, height: 22))
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(image: fa_plus_square_image, style: .Plain, target: self, action: Selector("createNewRecommendationButtonPressed"))
        newRecommendationButton.tintColor = .colorFromHex(0x59c939)
        
        self.toolbarItems = [flexibleSpace, newRecommendationButton]
    }
    
}
















