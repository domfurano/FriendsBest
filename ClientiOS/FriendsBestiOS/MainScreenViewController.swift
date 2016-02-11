//
//  MainScreenViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class MainScreenViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    let userDefaults: NSUserDefaults = NSUserDefaults()
    var searchController: UISearchController = UISearchController(searchResultsController: nil)

    var leftSwipeGR: UISwipeGestureRecognizer?
    var rightSwipeGR : UISwipeGestureRecognizer?
    
    let baseCard = BaseCardView()
    
    var cardViews: [(Prompt, PromptCardView)] = []
    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {
        /* Navigation bar */
        let historyIcon: FAKFontAwesome = FAKFontAwesome.historyIconWithSize(32)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: historyIcon.imageWithSize(CGSize(width: 32, height: 32)), style: .Plain, target: self, action: Selector("queryHistoryButtonClicked"))
        
        searchController.searchBar.barTintColor = UIColor.clearColor()
        searchController.searchBar.backgroundColor = UIColor.clearColor()
        searchController.view.backgroundColor = UIColor.clearColor()
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        /* Gesture recognizers */
        self.leftSwipeGR = UISwipeGestureRecognizer(target: self, action: "didSwipeLeft")
        self.rightSwipeGR = UISwipeGestureRecognizer(target: self, action: "didSwipeRight")
        self.leftSwipeGR!.direction = .Left
        self.rightSwipeGR!.direction = .Right
        
        self.view.addGestureRecognizer(self.leftSwipeGR!)
        self.view.addGestureRecognizer(self.rightSwipeGR!)
        
        /* Facebook */
        if FBSDKAccessToken.currentAccessToken() == nil {
            navigationController?.pushViewController(FacebookLoginViewController(), animated: false)
        } else {
            print(FBSDKAccessToken.currentAccessToken().tokenString)
            // TODO: Key exchange and login with FriendsBest server
        }
        
        baseCard.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(baseCard)
        
        User.instance.promptsFetchedClosure = {
            [weak self] in
            self?.showPromptCards()
            self?.view.setNeedsDisplay()
        }
        
        addConstraints()
    }
    
    func didSwipeLeft() {
        if self.cardViews.count < 1 {
            return
        }
        
        if !cardViews.last!.1.pointInside(self.leftSwipeGR!.locationInView(self.view), withEvent: nil) {
            return
        }
        
        UIView.animateWithDuration(
            NSTimeInterval(0.33),
            animations: {
                () -> Void in
                // Runs on main thread (UIThread)
                let promptAndCard = self.cardViews.last!
                promptAndCard.1.frame = promptAndCard.1.frame.offsetBy(dx: -UIScreen.mainScreen().bounds.width, dy: 0)
            },
            completion: {
                (Bool) -> Void in
                // Runs on main thread (UIThread)
                let promptAndCard = self.cardViews.removeLast()
                promptAndCard.1.removeFromSuperview()
            }
        )
    }
    
    func didSwipeRight() {
        if self.cardViews.count < 1 {
            return
        }
        
        if !cardViews.last!.1.pointInside(self.leftSwipeGR!.locationInView(self.view), withEvent: nil) {
            return
        }
        
        UIView.animateWithDuration(
            NSTimeInterval(0.33),
            animations: {
                () -> Void in
                let promptAndCard = self.cardViews.last!
                promptAndCard.1.frame = promptAndCard.1.frame.offsetBy(dx: UIScreen.mainScreen().bounds.width, dy: 0)
            },
            completion: {
                (Bool) -> Void in
                let promptAndCard = self.cardViews.removeLast()
                promptAndCard.1.removeFromSuperview()
                
                let newController = NewRecommendationViewController()
                
                newController.tagsField.text = promptAndCard.0.tagString
//                newController.tagsField.enabled = false
                // TODO: Fix NewRecommendationViewController so it doesn't crash when 
                //       tagsField is disabled
                
                self.navigationController?.pushViewController(newController, animated: true)
            }
        )
    }
    
    func showPromptCards() {
        for prompt in User.instance.prompts {
            for promptAndCard in self.cardViews {
                if prompt.ID == promptAndCard.0.ID {
                    return
                }
            }
            let cardView: PromptCardView = PromptCardView()
            self.cardViews.append((prompt, cardView))
            cardView.prompt = prompt // Ugh... Get the prompt outta there
            self.view.addSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            addPrompCardConstraints(cardView)
        }
    }
    
    func addPrompCardConstraints(card: PromptCardView) {
        view.addConstraint(
            NSLayoutConstraint(
                item: card,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: card,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: card,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.7,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: card,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.7,
                constant: 0.0))
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Toolbar */
        NetworkDAO.instance.getPrompt()
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        setToolbarItems()
    }
    
    
    /* Navigation bar */
    
    func queryHistoryButtonClicked() {
        navigationController?.pushViewController(QueryHistoryViewController(), animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchBarText = searchBar.text {
            let tags: [String] = searchBarText.componentsSeparatedByString(" ").filter({$0 != ""})
            NetworkDAO.instance.postNewQuery(tags)
//            let query: Query? = User.instance.queryHistory.getQueryFromTags(tags)
            navigationController?.pushViewController(SolutionsViewController(tags: tags), animated: true)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Could use this to disallow characters in the search field.
        return true
    }
    
    
    /* Toolbar */
    
    func settingsButtonPressed() {
        NSLog("Settings button pressed.")
    }
    
    func profileButtonPressed() {
        NSLog("Profile button pressed.")
    }
    
    func newRecommendationButtonPressed() {
        NSLog("New recommnedation button pressed")
        navigationController?.pushViewController(NewRecommendationViewController(), animated: true)
    }
    
    private func setToolbarItems() {
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let fa_cog: FAKFontAwesome = FAKFontAwesome.cogIconWithSize(32)
        let fa_cog_image: UIImage = fa_cog.imageWithSize(CGSize(width: 32, height: 32))
        let settingsButton: UIBarButtonItem = UIBarButtonItem(image: fa_cog_image, style: .Plain, target: self, action: Selector("settingsButtonPressed"))
        
        let profilePic: UIView = FBSDKProfilePictureView(frame: CGRectMake(0, 0, 32, 32))
        
        let profileButton: UIButton = UIButton(type: UIButtonType.Custom)
        profileButton.frame = profilePic.frame
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = 10
        profileButton.addSubview(profilePic)
        profileButton.addTarget(self, action: Selector("profileButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusSquareIconWithSize(32)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 32, height: 32))
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(image: fa_plus_square_image, style: .Plain, target: self, action: Selector("newRecommendationButtonPressed"))
        newRecommendationButton.tintColor = UIColor.colorFromHex(0x00d735)

        self.toolbarItems = [settingsButton, flexibleSpace, profileBBItem, flexibleSpace, newRecommendationButton]
    }
    
    func addConstraints() {
        view.addConstraint(
            NSLayoutConstraint(
                item: baseCard,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: baseCard,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: baseCard,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.7,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: baseCard,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.7,
                constant: 0.0))
    }
}
