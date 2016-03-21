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
                UIColor.whiteColor().CGColor,
                UIColor.colorFromHex(0xe8edef).CGColor
            ],
            frame: self.frame,
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
    
    /* Subviews */
    let baseCard: BaseCardView = BaseCardView()
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
    }
    
    
    /*** Koloda ***/
     
    // delegate
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
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
        return nil
    }
    
    /*** end Koloda ***/
    
    
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
    var fa_plus_square_image: UIImage? = nil
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
        fa_plus_square_image = fa_plus_square.imageWithSize(CGSize(width: 32, height: 32))
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
            
//            view.insertSubview(cardView, belowSubview: recommendationPicker)
//            view.addSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            kolodaView.addSubview(cardView)
        }
        
//        self.cardsToAnimate = self.cardViews.filter { (cardView) -> Bool in
//            return cardView.prompt!.new
//        }
        
        kolodaView.reloadData()
        
//        animateCardPresentation()
//        self.repositionCards()
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
            fa_plus_square_image
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
