//
//  MainScreenViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit


class MainScreenViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    var searchController: UISearchController!

    
    override func loadView() {
        view = MainView()
    }
    
    override func viewDidLoad() {
        /* Navigation bar */
        navigationController?.navigationBarHidden = false
        let historyIcon: FAKFontAwesome = FAKFontAwesome.historyIconWithSize(22)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: historyIcon.imageWithSize(CGSize(width: 20, height: 20)), style: .Plain, target: self, action: Selector("queryHistoryButtonClicked"))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "queryHistoryButtonClicked")
        navigationController?.navigationBar.barTintColor = UIColor.grayColor()
        
        searchController = UISearchController(searchResultsController:  nil)
        searchController.searchBar.barTintColor = UIColor.grayColor()
        searchController.searchBar.backgroundColor = UIColor.grayColor()
        searchController.view.backgroundColor = UIColor.grayColor()
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        navigationItem.titleView = searchController.searchBar
//        definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Toolbar */
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
        
        let settingsButton: UIBarButtonItem = UIBarButtonItem.init(title: "\u{2699}", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("settingsButtonPressed"))
        
        let profileButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: Selector("profileButtonPressed"))
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusIconWithSize(22)
        fa_plus_square.addAttribute("NSForegroundColorAttributeName", value: UIColor.colorFromHex(0x59c939))
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 22, height: 22))
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(image: fa_plus_square_image, style: .Plain, target: self, action: Selector("newRecommendationButtonPressed"))

        self.toolbarItems = [settingsButton, flexibleSpace, profileButton, flexibleSpace, newRecommendationButton]
    }
}
