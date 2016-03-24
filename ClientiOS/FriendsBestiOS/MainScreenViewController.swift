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
        
        CommonUI.drawGradientForContext(
            [
                CommonUI.topGradientColor,
                CommonUI.bottomGradientColor
            ],
            frame: self.bounds,
            context: context
        )
    }
}


class MainScreenViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate, KolodaViewDataSource, KolodaViewDelegate {
    
    static let instance: MainScreenViewController = MainScreenViewController()
    
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
    let smallProfilePicture: UIImageView = CommonUI.smallProfilePicture!
    
    /* FA Icons */
    let historyIconButtonAlert: UIButton = CommonUI.searchHistoryButton(true)
    let historyIconButtonPlain: UIButton = CommonUI.searchHistoryButton(false)
    
    /* State */
    var recommendationPickerShown: Bool = false
    
    
    override func loadView() {
        view = MainView()        
    }
    
    override func viewDidLoad() {
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
            action: #selector(MainScreenViewController.queryHistoryButtonClicked),
            forControlEvents: .TouchUpInside
        )
        historyIconButtonPlain.addTarget(
            self,
            action: #selector(MainScreenViewController.queryHistoryButtonClicked),
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
            action: #selector(MainScreenViewController.pickCustom(_:)),
            forControlEvents: .TouchUpInside
        )
        
        recommendationPicker.linkTypeButton.addTarget(
            self,
            action: #selector(MainScreenViewController.pickLink(_:)),
            forControlEvents: .TouchUpInside
        )
        
        recommendationPicker.placeTypeButton.addTarget(
            self,
            action: #selector(MainScreenViewController.pickPlace(_:)),
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
        addConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        if recommendationPickerShown {
            navigationController?.navigationBarHidden = true
        } else {
            navigationController?.navigationBarHidden = false
        }
        navigationController?.toolbarHidden = false
                
        
        setToolbarItems()
    }
    
    
    /*** Delegate implementation ***/
    
    func showPromptCards() {
        var changed: Bool = false
        outerloop: for prompt in User.instance.prompts.prompts {
            for cardView in self.cardViews { // This is some N^2 bullshit
                if cardView.prompt!.ID == prompt.ID {
                    continue outerloop
                }
            }
            
            changed = true
            // TODO: Change to koloda view
            let cardView: PromptCardView = PromptCardView(frame: CGRectZero, prompt: prompt)
            self.cardViews.append(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            kolodaView.addSubview(cardView)
        }
        
        if changed {
            kolodaView.reloadData()
        }
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
        for prompt in User.instance.prompts.prompts {
            FBNetworkDAO.instance.deletePrompt(prompt.ID)
        }
        for cv in cardViews {
            cv.removeFromSuperview()
        }
        cardViews.removeAll()
        User.instance.prompts.prompts.removeAll()
        FBNetworkDAO.instance.getPrompts()
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
        let homeButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.home_image,
            style: .Plain,
            target: self,
            action: #selector(MainScreenViewController.homeButtonPressed)
        )
        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
        
        smallProfilePicture.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        smallProfilePicture.contentMode = .ScaleAspectFit
        let profileButton: UIButton = UIButton(type: UIButtonType.Custom)
        profileButton.frame = smallProfilePicture.frame
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        profileButton.addSubview(smallProfilePicture)
        profileButton.addTarget(
            self,
            action: #selector(MainScreenViewController.profileButtonPressed),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.fa_plus_square_image_fbGreen,
            style: .Plain,
            target: self,
            action: #selector(MainScreenViewController.newRecommendationButtonPressed)
        )
        newRecommendationButton.tintColor = CommonUI.fbGreen
        
        let fa_close: FAKFontAwesome = FAKFontAwesome.closeIconWithSize(32.0)
        let fa_close_image: UIImage = fa_close.imageWithSize(CGSize(width: 32.0, height: 32.0))
        let closeRecommendationPickerButton: UIBarButtonItem = UIBarButtonItem(
            image: fa_close_image,
            style: .Plain,
            target: self,
            action: #selector(MainScreenViewController.closeRecommendationPickerButtonPressed)
        )
        closeRecommendationPickerButton.tintColor = UIColor.redColor()
        
        regToolBar = [homeButton, CommonUI.flexibleSpace, profileBBItem, CommonUI.flexibleSpace, newRecommendationButton]
        
        recPickToolBar = [CommonUI.flexibleSpace, closeRecommendationPickerButton]
        
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
