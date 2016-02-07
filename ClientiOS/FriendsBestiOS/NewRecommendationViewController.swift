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
    
    var activeTextField: UITextField? = nil
    var activeTextView: UITextView? = nil
    
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
        
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleField.translatesAutoresizingMaskIntoConstraints = false
        
        commentsLabel.translatesAutoresizingMaskIntoConstraints = false
        commentsField.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints()
        
        // Register for keyboard events
        registerForKeyboardNotifications()
    }
    

    
    override func viewWillAppear(animated: Bool) {
        title = "New Recommendation"
        edgesForExtendedLayout = UIRectEdge.None
        setToolbarItems()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // Tags field gets focus when view appears
        tagsField.becomeFirstResponder()
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("keyboardWasShown:"),
            name: UIKeyboardDidShowNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("keyboardWillBeHidden:"),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        let scrollViewFrame: CGRect = self.scrollView.frame
        let mainScreenBounds = UIScreen.mainScreen().bounds
        let keyboardFrame: CGRect = aNotification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        
        let distanceBetweenNavBarAndKeyboard = mainScreenBounds.height - scrollViewFrame.origin.x - keyboardFrame.height
        let midpoint = distanceBetweenNavBarAndKeyboard / 2
        
        if self.activeTextField != nil {
            let activeTextFieldFrame: CGRect = self.activeTextField!.frame
            scrollView.setContentOffset(CGPointMake(0.0, activeTextFieldFrame.midY - midpoint), animated: true)
        }
        
        if self.activeTextView != nil {
            let activeTextViewFrame: CGRect = self.activeTextView!.frame            
            self.scrollView.setContentOffset(CGPointMake(0.0, activeTextViewFrame.midY - midpoint), animated:  true)
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.activeTextView = textView
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.activeTextView = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == tagsField {
            titleField.becomeFirstResponder()
            return false
        } else if textField == titleField {
            commentsField.becomeFirstResponder()
            return false
        } else {
            commentsField.resignFirstResponder()
            return true
        }
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
            // TODO: Show the user an error.
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
















