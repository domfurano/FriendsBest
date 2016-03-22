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
import Koloda


class MainView: UIView {
    
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)
        
        CommonUIElements.drawGradientForContext(
            [
                UIColor.colorFromHex(0xfefefe).CGColor,
                UIColor.colorFromHex(0xe8edef).CGColor
            ],
            frame: self.bounds,
            context: context
        )
    }
    
}


class MainScreenViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate, KolodaViewDataSource, KolodaViewDelegate {
    
    /* Google */
    let placesClient: GMSPlacesClient = GMSPlacesClient()
    var placePicker: GMSPlacePicker?
    var currentPlace: GMSPlace? = nil // TODO: Move this to possible the User class
    
    /* KolodaView */
    var kolodaView: KolodaView = KolodaView()
    
    /* Search Controller */
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    /* Toolbars */
    var regToolBar: [UIBarButtonItem]?
    var recPickToolBar: [UIBarButtonItem]?
    
    /* Subviews */
    let baseCard: BaseCardView = BaseCardView()
    let recommendationPicker: RecommendationTypePickerView = RecommendationTypePickerView()
    var cardViews: [PromptCardView] = []
    
    /* FA Icons */
    let historyIconButtonAlert: UIButton = CommonUIElements.searchHistoryButton(true)
    let historyIconButtonPlain: UIButton = CommonUIElements.searchHistoryButton(false)
    
    /* State */
    var recommendationPickerShown: Bool = false
    
    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {
        /* Facebook */ // TODO: Add this to a "loading" viewcontroller
        if FBSDKAccessToken.currentAccessToken() == nil {
            navigationController?.pushViewController(FacebookLoginViewController(), animated: false)
        } else {
            User.instance.facebookID = FBSDKAccessToken.currentAccessToken().userID
        }
        
        /* ViewController */
        
        definesPresentationContext = true
        
        
        /* Search controller */
        
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .Minimal
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
        
        
        /* Koloda */
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        
        /* Subviews */
        
        baseCard.translatesAutoresizingMaskIntoConstraints = false
        recommendationPicker.translatesAutoresizingMaskIntoConstraints = false
        kolodaView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(baseCard)
        view.addSubview(kolodaView)
        view.addSubview(recommendationPicker)
        view.addSubview(recommendationPicker.customTypeButton)
        view.addSubview(recommendationPicker.linkTypeButton)
        view.addSubview(recommendationPicker.placeTypeButton)
        
        recommendationPicker.hide() // This call must occur after the view has been added to the view hierarchy.
        
        
        /* Actions */
        
        recommendationPicker.customTypeButton.addTarget(
            self,
            action: Selector("pickCustom:"),
            forControlEvents: .TouchUpInside
        )
        
        recommendationPicker.linkTypeButton.addTarget(
            self,
            action: Selector("pickLink:"),
            forControlEvents: .TouchUpInside
        )
        
        recommendationPicker.placeTypeButton.addTarget(
            self,
            action: Selector("pickPlace:"),
            forControlEvents: .TouchUpInside
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
    }
    
    override func viewWillAppear(animated: Bool) {
        FBNetworkDAO.instance.getPrompts()
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        if recommendationPickerShown {
            navigationController?.navigationBarHidden = true
        } else {
            navigationController?.navigationBarHidden = false
        }
        navigationController?.toolbarHidden = false
    }
    
    
    /*** Delegate implementation ***/
    
    func showPromptCards() {
        outerloop: for prompt in User.instance.prompts.prompts {
            for cardView in self.cardViews { // This is some N^2 bullshit
                if cardView.prompt!.ID == prompt.ID {
                    continue outerloop
                }
            }
            
            // TODO: Change to koloda view
            let cardView: PromptCardView = PromptCardView(frame: CGRectZero, prompt: prompt)
            self.cardViews.append(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            kolodaView.addSubview(cardView)
        }
        
        kolodaView.reloadData()
    }
    
    func showAlert() {
        let historyIconBarButtonAlert: UIBarButtonItem = UIBarButtonItem(customView: historyIconButtonAlert)
        navigationItem.leftBarButtonItem = historyIconBarButtonAlert
    }
    
    
    /*** Koloda ***/
     
    var didSwipeRight: Bool = false
    
     // delegate
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        if direction == SwipeResultDirection.Left {
            cardViews[Int(index)].removeFromSuperview()
        } else if direction == SwipeResultDirection.Right {
            didSwipeRight = true
            newRecommendationButtonPressed()
        } else {
            fatalError()
        }
        //Example: loading more cards
        //            if index >= 3 {
        //                numberOfCards = 6
        //                kolodaView.reloadData()
        //            }
    }
    
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Example: reloading
        //        kolodaView.resetCurrentCardNumber()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://yalantis.com/")!)
    }
    
    // datasource
    
    func koloda(kolodaNumberOfCards koloda:KolodaView) -> UInt {
        return UInt(cardViews.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        return cardViews[Int(index)]
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return KolodaOverlayView()
    }
    
    /*** end Koloda ***/
    
    
    /* Toolbar */
    
    func setToolbarItems() {
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let home: FAKFontAwesome = FAKFontAwesome.homeIconWithSize(32.0)
        let home_image: UIImage = home.imageWithSize(CGSize(width: 32, height: 32))
        let homeButton: UIBarButtonItem = UIBarButtonItem(
            image: home_image,
            style: .Plain,
            target: self,
            action: Selector("homeButtonPressed")
        )
        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
        
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
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusSquareIconWithSize(32)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 32, height: 32))
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
            image: fa_plus_square_image,
            style: .Plain,
            target: self,
            action: Selector("newRecommendationButtonPressed")
        )
        newRecommendationButton.tintColor = UIColor.colorFromHex(0x00d735)
        
        let fa_close: FAKFontAwesome = FAKFontAwesome.closeIconWithSize(32.0)
        let fa_close_image: UIImage = fa_close.imageWithSize(CGSize(width: 32.0, height: 32.0))
        let closeRecommendationPickerButton: UIBarButtonItem = UIBarButtonItem(
            image: fa_close_image,
            style: .Plain,
            target: self,
            action: Selector("closeRecommendationPickerButtonPressed")
        )
        closeRecommendationPickerButton.tintColor = UIColor.redColor()
        
        regToolBar = [homeButton, flexibleSpace, profileBBItem, flexibleSpace, newRecommendationButton]
        
        recPickToolBar = [flexibleSpace, closeRecommendationPickerButton]
        
        toolbarItems = regToolBar
    }
    
    
    /*** Toolbar functions ***/
    
    func homeButtonPressed() {
        NSLog("Home button pressed.")
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
        navigationController?.navigationBarHidden = true
        setToolbarItems(recPickToolBar, animated: true)
        showNewRecommendationViews()
    }
    
    func closeRecommendationPickerButtonPressed() {
        navigationController?.navigationBarHidden = false
        setToolbarItems(regToolBar, animated: true)
        hideNewRecommendationViews(false)
        if didSwipeRight {
            kolodaView.revertAction()
            didSwipeRight = false
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
    
    
    /*** Recommendation Picker ***/
    
    func pickCustom(sender: UIButton) {
        navigationController?.pushViewController(NewRecommendationViewController(), animated: true)
    }
    
    func pickLink(sender: UIButton) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        navigationController?.pushViewController(WebViewController(), animated: true)
    }
    
    func pickPlace(sender: UIButton) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
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
    
    
    /*** Navigation bar ***/
    
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
    

    /*** Constraints ***/
    
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
                multiplier: 0.9,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: baseCard,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.75,
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
                multiplier: 1.0,
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
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: kolodaView,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Width,
                multiplier: 0.9,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: kolodaView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0.75,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: kolodaView,
                attribute: NSLayoutAttribute.CenterX,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        view.addConstraint(
            NSLayoutConstraint(
                item: kolodaView,
                attribute: NSLayoutAttribute.CenterY,
                relatedBy: NSLayoutRelation.Equal,
                toItem: view,
                attribute: NSLayoutAttribute.CenterY,
                multiplier: 1.0,
                constant: 0.0))
    }
}
