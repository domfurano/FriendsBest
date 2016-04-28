//
//  TestViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/12/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class QueryHistoryViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    var filteredQueries: [Query] = []
    var searching: Bool {
        return searchController.active && searchController.searchBar.text != ""
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        /* NECESSARY FOR DYNAMIC CELL HEIGHT */
        tableView.estimatedRowHeight =  60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        definesPresentationContext = true
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.barTintColor = CommonUI.navbarGrayColor
        searchController.searchBar.translucent = false
        searchController.searchBar.autocapitalizationType = .None
        tableView.tableHeaderView = searchController.searchBar
        
        /* Navigation bar */
        
        title = "Search History"
        
        let chevronLeftIcon: FAKFontAwesome = FAKFontAwesome.chevronLeftIconWithSize(32.0)
        let chevronLeftImage: UIImage = chevronLeftIcon.imageWithSize(CGSize(width: 32.0, height: 32.0))
        let leftBBItem: UIBarButtonItem = UIBarButtonItem(
            image: chevronLeftImage,
            style: .Plain,
            target: self,
            action: #selector(QueryHistoryViewController.back)
        )
        leftBBItem.tintColor = UIColor.whiteColor()
        
        navigationItem.leftBarButtonItem = leftBBItem
        
        
        /* Tableview datasource and delegate */
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        /* Tableview styling */
        
        tableView.separatorStyle = .None
        
        /* Refresh Control */
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.colorFromHex(0xD9DCDF)
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(QueryHistoryViewController.refreshData), forControlEvents: .ValueChanged)
        
        USER.closureQueryNew = { [weak self] (query) in
            self?.tableView.reloadData()
        }
        USER.closureQueryDeleted = { [weak self] in
            self?.tableView.reloadData()
        }
        USER.closureQueriesNew = { [weak self] in
            self?.tableView.reloadData()
        }
        
//        FBNetworkDAO.instance.getQueries({
//            [weak self] in
//            self?.tableView.reloadData()
//        })
        
//        NSNotificationCenter.defaultCenter().addObserver(
//            self,
//            selector: #selector(QueryHistoryViewController.showAlert),
//            name: "notifications",
//            object: nil
//        )
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = true
        
        navigationController?.navigationBar.barTintColor = CommonUI.navbarGrayColor
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
        
        
        navigationController?.navigationBar.translucent = false
        searchController.searchBar.translucent = false
    }
    
    override func viewDidLayoutSubviews() {
        self.view.sendSubviewToBack(self.tableView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.active = false
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredQueries.removeAll(keepCapacity: true)
        for query: Query in USER.myQueries {
            if query.tagString.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString) {
                filteredQueries.append(query)
            }
        }
        
        tableView.reloadData()
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.setShowsCancelButton(true, animated: false)
    }
    
    func didDismissSearchController(searchController: UISearchController) {        
        searchController.searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func refreshData() {
        refreshControl?.beginRefreshing()
        FBNetworkDAO.instance.getQueries({ [weak self] in
            self?.refreshControl?.endRefreshing()
        })
    }
    
    /* Toolbar */
    
    func setToolbarItems() {
        let homeButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.home_image,
            style: .Plain,
            target: self,
            action: #selector(QueryHistoryViewController.homeButtonPressed)
        )
        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
        
        let profileButton: UIButton = UIButton(type: .Custom)
        profileButton.frame = CGRect(x: 0, y: 0, width: 32.0, height: 32.0)
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        CommonUI.instance.setUIButtonWithFacebookProfileImage(profileButton)
        profileButton.addTarget(
            self,
            action: #selector(QueryHistoryViewController.profileButtonPressed),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.fa_plus_square_image,
            style: .Plain,
            target: self,
            action: #selector(QueryHistoryViewController.newRecommendationButtonPressed)
        )
        newRecommendationButton.tintColor = CommonUI.fbGreen
        
        toolbarItems = [homeButton, CommonUI.flexibleSpace, profileBBItem, CommonUI.flexibleSpace, newRecommendationButton]
    }
    
    func homeButtonPressed() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func profileButtonPressed() {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }
    
    func newRecommendationButtonPressed() {
        return
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredQueries.count
        }
        return USER.myQueries.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO: learn about reuseIdentifier
        let query: Query
        if searching {
            query = filteredQueries[indexPath.row]
        } else {
            query = USER.myQueries[indexPath.row]
        }
        let cell: QueryHistoryTableViewCell = QueryHistoryTableViewCell(query: query)
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let query: Query
        if searching {
            query = filteredQueries[indexPath.row]
        } else {
            query = USER.myQueries[indexPath.row]
        }
        navigationController?.pushViewController(SolutionsViewController(query: query, tags: query.tags), animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // TODO: Implement deletion and possibly custom delete control
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
//    var editingRow: Bool = false
//    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
//        editingRow = true
//    }
//    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
//        editingRow = false
//    }
//    func showAlert(notification: NSNotification) {
//        if !editingRow {
//            tableView.reloadData()
//        }
//    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let query: Query
        if searching {
            query = filteredQueries.removeAtIndex(indexPath.row)
            tableView.reloadData()
        } else {
            query = USER.myQueries.removeAtIndex(indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            tableView.endUpdates()
        }
        FBNetworkDAO.instance.deleteQuery(query, callback: nil)
    }
}













