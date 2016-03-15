//
//  NewRecommendationViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/26/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class NewRecommendationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // TODO: Need different recommendation modes
    
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelButtonPressed"))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.redColor()
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusIconWithSize(32)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 32, height: 32))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: fa_plus_square_image, style: .Plain, target: self, action: Selector("createNewRecommendationButtonPressed"))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.colorFromHex(0x00d735)
        
        styleControls()
        
        tagsField.delegate = self
        titleField.delegate = self
        commentsField.delegate = self
        NRinputAccessoryView.prevButton!.addTarget(
            self,
            action: "prevButtonPressed",
            forControlEvents: UIControlEvents.TouchUpInside
        )
        NRinputAccessoryView.nextButton!.addTarget(
            self,
            action: "nextButtonPressed",
            forControlEvents: UIControlEvents.TouchUpInside
        )
        NRinputAccessoryView.doneButton!.addTarget(
            self,
            action: "doneButtonPressed",
            forControlEvents: UIControlEvents.TouchUpInside
        )
        
        /* Fonts */
        tagsField.font = UIFont(name: AppSettings.UITextFieldFontName, size: AppSettings.UITextFieldFontSize)
        titleField.font = UIFont(name: AppSettings.UITextFieldFontName, size: AppSettings.UITextFieldFontSize)
        commentsField.font = UIFont(name: AppSettings.UITextFieldFontName, size: AppSettings.UITextFieldFontSize)
        
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
        
        // Recognize touches in background
        self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("doneButtonPressed")))
    }
    
    override func viewWillAppear(animated: Bool) {
        title = "New Recommendation"
        edgesForExtendedLayout = UIRectEdge.None
        setToolbarItems()
        
    }
    
    func prevButtonPressed() {
        if self.activeTextField != nil {
            assert(self.activeTextField != tagsField)
            tagsField.becomeFirstResponder()
            self.activeTextField = tagsField
            return
        }
        
        if self.activeTextView != nil {
            self.titleField.becomeFirstResponder()
            self.activeTextView = nil
            self.activeTextField = self.titleField
            return
        }
    }
    
    func nextButtonPressed() {
        assert(self.activeTextView == nil)
        
        if self.activeTextField != nil {
            assert(self.activeTextView == nil)
            if self.activeTextField == self.tagsField {
                self.titleField.becomeFirstResponder()
                self.activeTextField = titleField
                NRinputAccessoryView.prevButton!.enabled = true
            } else {
                self.commentsField.becomeFirstResponder()
                self.activeTextField = nil
                self.activeTextView = self.commentsField
            }
        }
    }
    
    func doneButtonPressed() {
        self.scrollView.endEditing(true)
        self.scrollView.setContentOffset(CGPointMake(0.0, 0.0), animated: true)
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
    
    // This method gets called when a user selects a different textfield or textview
    // even if the keyboard is already shown.
    func keyboardWasShown(aNotification: NSNotification) {
        if self.activeTextView == nil {
            self.scrollView.setContentOffset(CGPointZero, animated: true)
            return
        }
        
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
            self.scrollView.setContentOffset(CGPointMake(0.0, activeTextViewFrame.midY - midpoint), animated: true)
        }
    }
    
    func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
        self.activeTextView = nil
        
        if textField == self.tagsField {
            NRinputAccessoryView.prevButton!.enabled = false
            NRinputAccessoryView.prevButton!.hidden = false
            NRinputAccessoryView.nextButton!.enabled = true
            NRinputAccessoryView.nextButton!.hidden = false
            NRinputAccessoryView.doneButton!.enabled = false
            NRinputAccessoryView.doneButton!.hidden = true
        }
        
        if textField == self.titleField {
            NRinputAccessoryView.prevButton!.enabled = true
            NRinputAccessoryView.prevButton!.hidden = false
            NRinputAccessoryView.nextButton!.enabled = true
            NRinputAccessoryView.nextButton!.hidden = false
            NRinputAccessoryView.doneButton!.enabled = false
            NRinputAccessoryView.doneButton!.hidden = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.activeTextView = textView
        self.activeTextField = nil
        
        NRinputAccessoryView.prevButton!.enabled = true
        NRinputAccessoryView.prevButton!.hidden = false
        NRinputAccessoryView.nextButton!.enabled = false
        NRinputAccessoryView.nextButton!.hidden = true
        NRinputAccessoryView.doneButton!.enabled = true
        NRinputAccessoryView.doneButton!.hidden = false
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
        tagsField.inputAccessoryView = NRinputAccessoryView
        
        titleLabel.text = "Title"
        titleField.backgroundColor = UIColor.whiteColor()
        titleField.borderStyle = UITextBorderStyle.RoundedRect
        titleField.returnKeyType = UIReturnKeyType.Next
        titleField.keyboardAppearance = .Dark
        titleField.inputAccessoryView = NRinputAccessoryView
        
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
                multiplier: 0.3,
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
    
    func cancelButtonPressed() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func createNewRecommendationButtonPressed() {
        guard let description: String = titleField.text, let tagsString: String = tagsField.text else {
            return
        }
        
        if description.isEmpty || tagsString.isEmpty {
            return
        }
        
        let comments = commentsField.text == nil ? "" : commentsField.text!
        let tags = tagsString.characters.split{ $0 == " " }.map(String.init)
        FBNetworkDAO.instance.postNewRecommendtaion(description, type: Recommendation.RecommendationType.TEXT.rawValue, comments: comments, recommendationTags: tags) // TODO: handle multiple types
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func setToolbarItems() {
//        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//        
//        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusIconWithSize(22)
//        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 22, height: 22))
//        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(image: fa_plus_square_image, style: .Plain, target: self, action: Selector("createNewRecommendationButtonPressed"))
//        newRecommendationButton.tintColor = .colorFromHex(0x59c939)
//        
//        self.toolbarItems = [flexibleSpace, newRecommendationButton]
    }
    
}
















