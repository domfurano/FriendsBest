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
import GoogleMaps


class MainView: UIView {
    
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)
        
        CommonUIElements.drawGradientForContext(
            [
                UIColor.whiteColor().CGColor,
                UIColor.colorFromHex(0xe8edef).CGColor
            ],
            frame: self.frame,
            context: context
        )
    }
    
}


class MainScreenViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    /* Google */
    let placesClient: GMSPlacesClient = GMSPlacesClient()
    var placePicker: GMSPlacePicker?
    var currentPlace: GMSPlace? = nil // TODO: Move this to possible the User class
    
    var searchController: UISearchController = UISearchController(searchResultsController: nil)

    /* Gesture recognizers */
//    var panGR: UIPanGestureRecognizer?
//    var leftSwipeGR: UISwipeGestureRecognizer?
//    var rightSwipeGR : UISwipeGestureRecognizer?
    
    /* Subviews */
    let baseCard = BaseCardView()
    let recommendationPicker: RecommendationTypePickerView = RecommendationTypePickerView()
    var cardViews: [PromptCardView] = []
    
    /* FA Icons */
    let historyIconButtonAlert: UIButton = CommonUIElements.searchHistoryButton(true)
    let historyIconButtonPlain: UIButton = CommonUIElements.searchHistoryButton(false)
    
    /* State */
    var recommendationPickerShown: Bool = false
    
    
    /************************************************************************************************************************/
    
    override func loadView() {
        view = MainView()
        view.multipleTouchEnabled = true
        
        /* Facebook */ // TODO: Add this to a "loading" viewcontroller
        if FBSDKAccessToken.currentAccessToken() == nil {
            navigationController?.pushViewController(FacebookLoginViewController(), animated: false)
        } else {
            User.instance.facebookID = FBSDKAccessToken.currentAccessToken().userID
        }
    }
    
    override func viewDidLoad() {
        /* ViewController */
        
        definesPresentationContext = true
        
        
        /* Navigation bar */
        
        navigationController?.navigationBar.layer.shadowOpacity = 0.33
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        navigationController?.navigationBar.layer.shadowRadius = 1.0
        
        
        /* Search controller */
        
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Prominent
        searchController.searchBar.placeholder = "Search"
        navigationItem.titleView = searchController.searchBar
        
        
        /* Search history button */
        
        let historyIconBarButtonPlain: UIBarButtonItem = UIBarButtonItem(customView: historyIconButtonPlain)
        
        historyIconButtonAlert.addTarget(
            self,
            action: Selector("queryHistoryButtonClicked"),
            forControlEvents: .TouchUpInside
        )
        historyIconButtonPlain.addTarget(
            self,
            action: Selector("queryHistoryButtonClicked"),
            forControlEvents: .TouchUpInside
        )
        navigationItem.leftBarButtonItem = historyIconBarButtonPlain

        
        /* Gesture recognizers */
        
//        panGR = UIPanGestureRecognizer(target: self, action: "didPan")
//        leftSwipeGR = UISwipeGestureRecognizer(target: self, action: "didSwipeLeft")
//        rightSwipeGR = UISwipeGestureRecognizer(target: self, action: "didSwipeRight")
//        leftSwipeGR!.direction = .Left
//        rightSwipeGR!.direction = .Right
//
//        view.addGestureRecognizer(panGR!)
//        view.addGestureRecognizer(leftSwipeGR!)
//        view.addGestureRecognizer(rightSwipeGR!)
        
        
        /* Subviews */
        
        baseCard.translatesAutoresizingMaskIntoConstraints = false
        recommendationPicker.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(baseCard)
        view.addSubview(recommendationPicker)
        view.addSubview(recommendationPicker.customTypeButton)
        view.addSubview(recommendationPicker.linkTypeButton)
        view.addSubview(recommendationPicker.placeTypeButton)
        
        
        /* Actions */
        
        recommendationPicker.placeTypeButton.addTarget(
            self,
            action: Selector("pickPlace:"),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        
        recommendationPicker.linkTypeButton.addTarget(
            self,
            action: Selector("pickLink:"),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        
        
        /* Closure implementations */
        
        User.instance.promptsFetchedClosure = {
            [weak self] in
            self?.showPromptCards()
        }
        
        User.instance.newSolutionAlert = {
            [weak self] in
            self?.showAlert()
        }
        
        User.instance.newRecommendationAlert = {
            [weak self] in
            self?.showAlert()
        }
        
        placesClient.currentPlaceWithCallback { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                print("Current Place error: \(error!.localizedDescription)")
                return
            }
            
            if let placeLikelihoods = placeLikelihoods {
                self.currentPlace = placeLikelihoods.likelihoods.first?.place
            }
        }
        
        setToolbarItems()        
        addConstraints()
        
        recommendationPicker.hide() // This call must occur after the view has been added to the view hierarchy.
    }
    
    override func viewWillAppear(animated: Bool) {
        FBNetworkDAO.instance.getPrompts()
        
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
//        if recommendingCard != nil {
//            recommendingCard = nil
//        }
    }
    
    
    
    let previousPoint: CGPoint = CGPoint()
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(view)
        NSLog("touchesBegan: \(touchPoint)")
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(view)
        
        let dX = previousPoint.
        
        let topCard: PromptCardView = cardViews.last!
        
        if topCard.pointInside(touchPoint, withEvent: event) {
            
        }
        
        NSLog("touchesMoved: \(touchPoint)")
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        let touch: UITouch = touches!.first!
        let touchPoint: CGPoint = touch.locationInView(view)
        NSLog("touchesCancelled: \(touchPoint)")
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch = touches.first!
        let touchPoint: CGPoint = touch.locationInView(view)
        NSLog("touchesEnded: \(touchPoint)")
    }
    
    func showAlert() {
        let historyIconBarButtonAlert: UIBarButtonItem = UIBarButtonItem(customView: historyIconButtonAlert)
        navigationItem.leftBarButtonItem = historyIconBarButtonAlert        
    }
    
    func pickPlace(sender: UIButton) {
        let center = CLLocationCoordinate2DMake(40.7676918, -111.8452524)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if self.recommendationPickerShown {
                self.hideNewRecommendationViews(false)
            }
            
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place attributions \(place.attributions)")
            } else {
                print("No place selected")
            }
        })
    }
    
    func pickLink(sender: UIButton) {
        navigationController?.pushViewController(WebViewController(), animated: true)
    }
    

    
    var newRecommendationButton: UIBarButtonItem? = nil
    func setToolbarItems() {
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let profilePic: UIView = FBSDKProfilePictureView(frame: CGRectMake(0, 0, 32, 32))
        let profileButton: UIButton = UIButton(type: UIButtonType.Custom)
        profileButton.frame = profilePic.frame
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        profileButton.addSubview(profilePic)
        profileButton.addTarget(
            self,
            action: Selector("profileButtonPressed"),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        let home: FAKFontAwesome = FAKFontAwesome.homeIconWithSize(32.0)
        let home_image: UIImage = home.imageWithSize(CGSize(width: 32, height: 32))
        let homeButton: UIBarButtonItem = UIBarButtonItem(
            image: home_image,
            style: .Plain,
            target: self,
            action: nil
        )
        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusSquareIconWithSize(32)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 32, height: 32))
        newRecommendationButton = UIBarButtonItem(
            image: fa_plus_square_image,
            style: .Plain,
            target: self,
            action: Selector("newRecommendationButtonPressed")
        )
        newRecommendationButton!.tintColor = UIColor.colorFromHex(0x00d735)
        
        toolbarItems = [homeButton, flexibleSpace, profileBBItem, flexibleSpace, newRecommendationButton!]
    }
    
    /************************************************************************************************************************/
    // Gesture handlers
    
//    func didPan() {
//        if self.cardViews.count < 1 || recommendationPickerShown {
//            return
//        }
//        
//        let topCard: PromptCardView = cardViews.last!
//        if !topCard.pointInside(panGR!.locationInView(topCard), withEvent: nil) {
//            return
//        }
//    }
//    
//    func didSwipeLeft() {
//        if self.cardViews.count < 1 || recommendationPickerShown {
//            return
//        }
//        
//        let topCard: PromptCardView = self.cardViews.last!
//        if !topCard.pointInside(self.leftSwipeGR!.locationInView(topCard), withEvent: nil) {
//            return
//        }
//        
//        UIView.animateWithDuration(
//            NSTimeInterval(0.33),
//            animations: {
//                () -> Void in
//                // Runs on main thread (UIThread)
//                topCard.frame = topCard.frame.offsetBy(dx: -UIScreen.mainScreen().bounds.width, dy: 0)
//            },
//            completion: {
//                (Bool) -> Void in
//                // Runs on main thread (UIThread)
//                let promptAndCard = self.cardViews.removeLast()
//                promptAndCard.removeFromSuperview()
////                self.repositionCards()
//            }
//        )
//    }
//    
//    var recommendingCard: PromptCardView?
//    func didSwipeRight() {
//        if self.cardViews.count < 1 || recommendationPickerShown {
//            return
//        }
//        
//        let topCard: PromptCardView = self.cardViews.last!
//        if !topCard.pointInside(self.rightSwipeGR!.locationInView(topCard), withEvent: nil) {
//            return
//        }
//        
//        UIView.animateWithDuration(
//            NSTimeInterval(0.33),
//            animations: {
//                () -> Void in
//                topCard.frame = topCard.frame.offsetBy(dx: UIScreen.mainScreen().bounds.width, dy: 0)
//            },
//            completion: {
//                (successful) -> Void in
//                self.recommendingCard = self.cardViews.removeLast()
//                self.recommendingCard!.removeFromSuperview()
//                
////                let newController = NewRecommendationViewController()
////                newController.tagsField.text = self.recommendingCard!.prompt!.tagString
////                newController.tagsField.enabled = false
//                // TODO: Fix NewRecommendationViewController so it doesn't crash when 
//                //       tagsField is disabled
//                
////                self.navigationController?.pushViewController(newController, animated: true)
//                
////                self.showNewRecommendationViews()
//            }
//        )
//    }
    
    /************************************************************************************************************************/
    
//    var cardsToAnimate: [PromptCardView] = []
    func showPromptCards() {
        outerloop: for prompt in User.instance.prompts.prompts {
            for cardView in self.cardViews { // This is some N^2 bullshit
                if cardView.prompt!.ID == prompt.ID {
                    continue outerloop
                }
            }
            
            let cardView: PromptCardView = PromptCardView(frame: CGRectZero, prompt: prompt)
            self.cardViews.append(cardView)
//            cardView.prompt = prompt // Ugh... Get the prompt outta there; TODO: remove data model object from PromptCardView class
            
            view.insertSubview(cardView, belowSubview: recommendationPicker)
//            view.addSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            addCardConstraints(cardView)
            
            cardView.frame = cardView.frame.offsetBy(dx: 0, dy: UIScreen.mainScreen().bounds.height)
        }
        
//        self.cardsToAnimate = self.cardViews.filter { (cardView) -> Bool in
//            return cardView.prompt!.new
//        }
        
//        animateCardPresentation()
//        self.repositionCards()
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
            FBNetworkDAO.instance.postNewQuery(tags)
            navigationController?.pushViewController(SolutionsViewController(tags: tags), animated: true)
        }
        self.searchController.active = false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Could use this to disallow characters in the search field.
        return true
    }
    
    
    /* Toolbar */
    
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
        if !recommendationPickerShown {
            showNewRecommendationViews()
        } else {
            hideNewRecommendationViews(false)
        }
    }
    
    func showNewRecommendationViews() {
        UIView.animateWithDuration(NSTimeInterval(0.33)) { () -> Void in
            self.recommendationPicker.show()
            self.view.layoutIfNeeded()
        }
        recommendationPickerShown = true
    }
    
    func hideNewRecommendationViews(immediately: Bool) {
        if immediately {
            recommendationPicker.hide()
            view.layoutIfNeeded()
        } else {
            UIView.animateWithDuration(NSTimeInterval(0.33), animations: { () -> Void in
                self.recommendationPicker.hide()
                self.view.layoutIfNeeded()
            })
        }
        recommendationPickerShown = false
    }
    
    func addConstraints() {
        // TODO: Eliminate this code. Create an abstract "Card" base class and have all card types inherit from it.
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
        
        view.addConstraint(
            NSLayoutConstraint(
                item: recommendationPicker,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: recommendationPicker,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.5,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: recommendationPicker,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: recommendationPicker,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.2,
                constant: 0.0))
    }
}
