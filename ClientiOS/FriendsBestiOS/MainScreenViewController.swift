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
    var searchController: UISearchController!

    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {
        /* Navigation bar */
        let historyIcon: FAKFontAwesome = FAKFontAwesome.historyIconWithSize(22)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: historyIcon.imageWithSize(CGSize(width: 20, height: 20)), style: .Plain, target: self, action: Selector("queryHistoryButtonClicked"))
        navigationController?.navigationBar.barTintColor = UIColor.grayColor()
        
        searchController = UISearchController(searchResultsController:  nil)
        searchController.searchBar.barTintColor = UIColor.grayColor()
        searchController.searchBar.backgroundColor = UIColor.grayColor()
        searchController.view.backgroundColor = UIColor.grayColor()
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
        
        /* Facebook */
        if FBSDKAccessToken.currentAccessToken() == nil {
            navigationController?.pushViewController(FacebookLoginViewController(), animated: false)
        } else {
            print(FBSDKAccessToken.currentAccessToken().tokenString)
//            userDefaults.setObject(FBSDKAccessToken.currentAccessToken(), forKey: "fb_access_token")
            // TODO: Key exchange and login with FriendsBest server
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Toolbar */
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        setToolbarItems()
    }
    
    
    /* Navigation bar */
    
    func queryHistoryButtonClicked() {
//        navigationController?.presentViewController(QueryHistoryViewController(), animated: true, completion: nil)
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
        
        let fa_cog: FAKFontAwesome = FAKFontAwesome.cogIconWithSize(22)
        let fa_cog_image: UIImage = fa_cog.imageWithSize(CGSize(width: 22, height: 22))
        let settingsButton: UIBarButtonItem = UIBarButtonItem(image: fa_cog_image, style: .Plain, target: self, action: Selector("settingsButtonPressed"))
        
        let fa_circle: FAKFontAwesome = FAKFontAwesome.circleIconWithSize(22)
        let fa_circle_image: UIImage = fa_circle.imageWithSize(CGSize(width: 22, height: 22))
        let profileButton: UIBarButtonItem = UIBarButtonItem(image: fa_circle_image, style: .Plain, target: self, action: Selector("profileButtonPressed"))
        profileButton.tintColor = .colorFromHex(0x3b5998)
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusIconWithSize(22)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 22, height: 22))
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(image: fa_plus_square_image, style: .Plain, target: self, action: Selector("newRecommendationButtonPressed"))
        newRecommendationButton.tintColor = .colorFromHex(0x59c939)

        self.toolbarItems = [settingsButton, flexibleSpace, profileButton, flexibleSpace, newRecommendationButton]
    }
}
