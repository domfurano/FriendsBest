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
    
//    static let instance: MainScreenViewController = MainScreenViewController() // ?????
    
    /* Google */
    let placesClient: GMSPlacesClient = GMSPlacesClient()
    var placePicker: GMSPlacePicker?
    var currentPlace: GMSPlace? = nil // TODO: Move this to possible the User class
    
    /* KolodaView */
    var kolodaView: KolodaView = KolodaView()
    
    /* Search Controller */
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    /* Toolbar */
    var regToolBar: [UIBarButtonItem]?
    
    /* Subviews */
    let baseCard: BaseCardView = BaseCardView()
    var cardViews: [PromptCardView] = []
    
    /* FA Icons */
    let historyIconButtonAlert: UIButton = CommonUI.searchHistoryButton(true)
    let historyIconButtonPlain: UIButton = CommonUI.searchHistoryButton(false)
    
    /* State */
    var recommendationPickerShown: Bool = false
    
    /* Recommendation Picker */
    var recommendationPicker: RecommendationPickerViewController = RecommendationPickerViewController()
    
    deinit {
        NSLog("MainScreenViewController - deinit")
    }
    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {
        
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
        kolodaView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(baseCard)
        view.addSubview(kolodaView)
        
        
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
        
        recommendationPicker.buttonPushedDelegate = { buttonType in
            switch buttonType {
            case .custom:
                self.pickCustom()
                break
            case .link:
                self.pickLink()
                break
            case .place:
                self.pickPlace()
                break
            }
        }
        
        recommendationPicker.pickerHiddenDelegate = {
            self.pickerHidden()
        }
        
        placesClient.currentPlaceWithCallback { (placeLikelihoods, error) -> Void in
            guard error == nil else {
                NSLog("Current Place error: \(error!.localizedDescription)")
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
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
        
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        setToolbarItems()
    }
    
    /*** Delegate implementation ***/
    
    func showPromptCards() {
        var changed: Bool = false
        outerloop: for prompt in User.instance.prompts.prompts {
            for cardView in self.cardViews {
                if cardView.prompt!.ID == prompt.ID {
                    continue outerloop
                }
            }
            
            changed = true
            let cardView: PromptCardView = PromptCardView(frame: CGRectZero, prompt: prompt)
            self.cardViews.append(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            kolodaView.addSubview(cardView)
        }
        
        if changed {
            kolodaView.resetCurrentCardIndex()
        }
    }
    
    func showAlert() {
        let historyIconBarButtonAlert: UIBarButtonItem = UIBarButtonItem(customView: historyIconButtonAlert)
        navigationItem.leftBarButtonItem = historyIconBarButtonAlert
    }
    
    
    /*** Koloda ***/
    
    var didSwipeRight: Bool = false
    var swipedTags: [String] = []
    
    // delegate
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        if direction == SwipeResultDirection.Left {
            let cardView: PromptCardView = cardViews[Int(index)]
            FBNetworkDAO.instance.deletePrompt(cardView.prompt!.ID)
        } else {
            didSwipeRight = true
            swipedTags = cardViews[Int(index)].prompt!.tags
            showNewRecommendationViews()
        }
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        if didSwipeRight {
            return
        }
        for prompt in User.instance.prompts.prompts {
            User.instance.prompts.deletePrompt(prompt.ID)
        }
        cardViews.removeAll()
        FBNetworkDAO.instance.getPrompts()
    }
    
    // datasource
    
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        return UInt(cardViews.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let cardView: PromptCardView = cardViews[Int(index)]
        cardView.setNeedsDisplay()
        return cardView
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
        
        let profileButton: UIButton = UIButton(type: .Custom)
        profileButton.frame = CGRect(x: 0, y: 0, width: 32.0, height: 32.0)
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        CommonUI.instance.setUIButtonWithFacebookProfileImage(profileButton)
        profileButton.addTarget(
            self,
            action: #selector(MainScreenViewController.profileButtonPressed),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.fa_plus_square_image,
            style: .Plain,
            target: self,
            action: #selector(MainScreenViewController.newRecommendationButtonPressed)
        )
        newRecommendationButton.tintColor = CommonUI.fbGreen
        
        regToolBar = [homeButton, CommonUI.flexibleSpace, profileBBItem, CommonUI.flexibleSpace, newRecommendationButton]
        
        toolbarItems = regToolBar
    }
    
    
    /*** Toolbar functions ***/
    
    func homeButtonPressed() {
        NSLog("Home button pressed.")
    }
    
    func profileButtonPressed() {
        NSLog("Profile button pressed.")
        
        let profileViewController: ProfileViewController = ProfileViewController()
        
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func newRecommendationButtonPressed() {
        showNewRecommendationViews()
    }
    
    func showNewRecommendationViews() {        
        recommendationPicker.modalPresentationStyle = .OverFullScreen
        navigationController?.presentViewController(recommendationPicker, animated: false, completion: nil)
        recommendationPickerShown = true
    }
    
    func pickerHidden() {
        recommendationPickerShown = false
        if didSwipeRight {
            didSwipeRight = false
            kolodaView.revertAction()
        }
    }
    
    
    /*** Recommendation Picker ***/
    
        func pickCustom() {
//            recommendationPicker.hide(true)
            navigationController?.pushViewController(NewRecommendationFormViewController(type: .TEXT, detail: "", tags: swipedTags), animated: true)
        }
    
        func pickLink() {
//            RecommendationTypePickerView.instance.hide(true)
            navigationController?.navigationBarHidden = false
            navigationController?.toolbarHidden = false
            navigationController?.pushViewController(WebViewController(), animated: true)
        }
    
        func pickPlace() {
//            RecommendationTypePickerView.instance.hide(true)
            navigationController?.navigationBarHidden = false
            navigationController?.toolbarHidden = false
            let center = CLLocationCoordinate2DMake(40.7676918, -111.8452524)
            let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
            let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
    
            let config = GMSPlacePickerConfig(viewport: viewport)
            placePicker = GMSPlacePicker(config: config)
    
            placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
                self.viewWillAppear(false)
    
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
                multiplier: 0.9,
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
                multiplier: 0.9,
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
