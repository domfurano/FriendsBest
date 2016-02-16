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
    
    var cardViews: [(prompt: Prompt, view: PromptCardView)] = []
    
    override func loadView() {
        view = MainView()
        
        /* Facebook */
        if FBSDKAccessToken.currentAccessToken() == nil {
            navigationController?.pushViewController(FacebookLoginViewController(), animated: false)
        }
    }
    
    override func viewDidLoad() {
        /* Navigation bar */
        let historyIcon: FAKFontAwesome = FAKFontAwesome.historyIconWithSize(32)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: historyIcon.imageWithSize(CGSize(width: 32, height: 32)), style: .Plain, target: self, action: Selector("queryHistoryButtonClicked"))
        
        /* Search controller */
        searchController.searchBar.barTintColor = UIColor.clearColor()
        searchController.searchBar.backgroundColor = UIColor.clearColor()
        searchController.view.backgroundColor = UIColor.clearColor()
//        searchController.view.alpha = 0.0??????
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        /* Refresh control */
//        UIRefreshControl may only be managed by a UITableViewController
//        let refreshControl: UIRefreshControl = UIRefreshControl()
//        refreshControl.backgroundColor = UIColor.greenColor()
//        refreshControl.tintColor = UIColor.whiteColor()
//        self.view.addSubview(refreshControl)
        
        /* Gesture recognizers */
        self.leftSwipeGR = UISwipeGestureRecognizer(target: self, action: "didSwipeLeft")
        self.rightSwipeGR = UISwipeGestureRecognizer(target: self, action: "didSwipeRight")
        self.leftSwipeGR!.direction = .Left
        self.rightSwipeGR!.direction = .Right
        
        self.view.addGestureRecognizer(self.leftSwipeGR!)
        self.view.addGestureRecognizer(self.rightSwipeGR!)
        
        baseCard.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(baseCard)
        
        User.instance.promptsFetchedClosure = {
            [weak self] in
            self?.showPromptCards()
            self?.view.layoutSubviews()
        }
        
        addConstraints()
        

    }
    
    override func viewWillAppear(animated: Bool) {
        NetworkDAO.instance.getPrompt()

        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        /* Toolbar */
        setToolbarItems()
    }
    
    func didSwipeLeft() {
        if self.cardViews.count < 1 {
            return
        }
        
        let topCard: PromptCardView = self.cardViews.last!.view
        if !topCard.pointInside(self.leftSwipeGR!.locationInView(topCard), withEvent: nil) {
            return
        }
        
        UIView.animateWithDuration(
            NSTimeInterval(0.33),
            animations: {
                () -> Void in
                // Runs on main thread (UIThread)
                topCard.frame = topCard.frame.offsetBy(dx: -UIScreen.mainScreen().bounds.width, dy: 0)
            },
            completion: {
                (Bool) -> Void in
                // Runs on main thread (UIThread)
                let promptAndCard = self.cardViews.removeLast()
                promptAndCard.view.removeFromSuperview()
            }
        )
    }
    
    func didSwipeRight() {
        if self.cardViews.count < 1 {
            return
        }
        
        let topCard: PromptCardView = self.cardViews.last!.view
        if !topCard.pointInside(self.rightSwipeGR!.locationInView(topCard), withEvent: nil) {
            return
        }
        
        UIView.animateWithDuration(
            NSTimeInterval(0.33),
            animations: {
                () -> Void in
                topCard.frame = topCard.frame.offsetBy(dx: UIScreen.mainScreen().bounds.width, dy: 0)
            },
            completion: {
                (Bool) -> Void in
                let promptAndCard = self.cardViews.removeLast()
                promptAndCard.view.removeFromSuperview()
                
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
                if prompt.ID == promptAndCard.prompt.ID {
                    return
                }
            }
            let cardView: PromptCardView = PromptCardView()
            self.cardViews.append((prompt, cardView))
            cardView.prompt = prompt // Ugh... Get the prompt outta there; TODO: remove data model object from PromptCardView class
            self.view.addSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            addCardConstraints(cardView)
        }
    }
    
    func addCardConstraints(card: PromptCardView) {
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
        self.searchController.active = false
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
        
        let profileViewController: ProfileViewController = ProfileViewController()
//        let transition: CATransition = CATransition()
//        transition.duration = 0.2;
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromTop
//        self.navigationController!.view.layer.addAnimation(transition, forKey: kCATransition)
        
        navigationController?.pushViewController(profileViewController, animated: true)
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
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        profileButton.addSubview(profilePic)
        profileButton.addTarget(self, action: Selector("profileButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusSquareIconWithSize(32)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 32, height: 32))
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(image: fa_plus_square_image, style: .Plain, target: self, action: Selector("newRecommendationButtonPressed"))
        newRecommendationButton.tintColor = UIColor.colorFromHex(0x00d735)

        self.toolbarItems = [settingsButton, flexibleSpace, profileBBItem, flexibleSpace, newRecommendationButton]
    }
    
    // TODO: Eliminate this code. Create an abstract "Card" base class and have all card types inherit from it.
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
