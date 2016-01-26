//
//  MainScreenViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/17/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    var queryHistoryViewController: QueryHistoryViewController = QueryHistoryViewController()
    
    var searchController: UISearchController!

    
    override func loadView() {
        super.loadView()
        view = MainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Navigation bar */
        navigationController?.navigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "queryHistoryButtonClicked")
        
        searchController = UISearchController(searchResultsController:  nil)
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Toolbar */
        navigationController?.toolbarHidden = false
        setToolbarItems()
    }
    
    
    /* Navigation bar */
    
    func queryHistoryButtonClicked() {
        navigationController?.pushViewController(queryHistoryViewController, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchBarText = searchBar.text {
            let tags: [String] = searchBarText.componentsSeparatedByString(" ").filter({$0 != ""})
            NetworkDAO.instance.postNewQuery(tags)
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
    }
    
    private func setToolbarItems() {
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let settingsButton: UIBarButtonItem = UIBarButtonItem.init(title: "\u{2699}", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("settingsButtonPressed"))
        
        let profileButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: Selector("profileButtonPressed"))
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("newRecommendationButtonPressed"))

        self.toolbarItems = [settingsButton, flexibleSpace, profileButton, flexibleSpace, newRecommendationButton]
    }
}
