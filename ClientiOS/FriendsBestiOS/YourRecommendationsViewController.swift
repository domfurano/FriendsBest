//
//  YourRecommendationsViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/24/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleMaps
import PINCache


class YourRecommendationsViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    let searchController = UISearchController(searchResultsController: nil)
    var filteredRecommendations: [UserRecommendation] = []
    var searching: Bool {
        return searchController.active && searchController.searchBar.text != ""
    }
    
    var placePicker: GMSPlacePicker?
    let cellID: String = "yourRecommendation"

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
        
        /* NECESSARY FOR DYNAMIC CELL HEIGHT */
        tableView.estimatedRowHeight =  128.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        definesPresentationContext = true
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.barTintColor = CommonUI.fbGreen
        searchController.searchBar.translucent = false
        searchController.searchBar.autocapitalizationType = .None
        tableView.tableHeaderView = searchController.searchBar
        
        
        tableView.registerClass(YourRecommendationTableViewCell.self, forCellReuseIdentifier: cellID)
        
        USER.closureUserRecommendationNew = { [weak self] in
            self?.tableView.reloadData()
        }
        USER.closureUserRecommendationsNew = { [weak self] in
            self?.tableView.reloadData()
        }
        USER.closureUserRecommendationDeleted = { [weak self] in
            self?.tableView.reloadData()
        }
        
        let leftBBitem: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.nbBackChevron,
            style: .Plain,
            target: self,
            action: #selector(YourRecommendationsViewController.back)
        )
        leftBBitem.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = leftBBitem
        title = "Your Recommendations"
        tableView.separatorStyle = .None
        
        /* Refresh Control */
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.colorFromHex(0x9BE887)
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(YourRecommendationsViewController.refreshData), forControlEvents: .ValueChanged)
        
//        FBNetworkDAO.instance.getRecommendationsForUser({
//            [weak self] in
//            self?.tableView.reloadData()
//        })
        
//        NSNotificationCenter.defaultCenter().addObserver(
//            self,
//            selector: #selector(YourRecommendationsViewController.showAlert),
//            name: "notifications",
//            object: nil
//        )
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = true
        
        navigationController?.navigationBar.barTintColor = CommonUI.fbGreen
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.active = false
    }
    
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredRecommendations.removeAll(keepCapacity: true)
        for myRecommendation: UserRecommendation in USER.myRecommendations {
            if myRecommendation.tagString.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
            || myRecommendation.placeName.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
            || myRecommendation.comments.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
            || myRecommendation.urlTitle.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString) {
                filteredRecommendations.append(myRecommendation)
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
        FBNetworkDAO.instance.getRecommendationsForUser({ [weak self] in
            self?.refreshControl?.endRefreshing()
        })
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredRecommendations.count
        }
        return USER.myRecommendations.count
    }
    
    var didCallBack: Bool = false
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recommendation: UserRecommendation
        if searching {
            recommendation = filteredRecommendations[indexPath.row]
        } else {
            recommendation = USER.myRecommendations[indexPath.row]
        }
        recommendation.closureUserRecommendationUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        let cell: YourRecommendationTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellID) as! YourRecommendationTableViewCell
        cell.updateFonts()
        cell.setupForViewing(
            recommendation.tagString,
            title: recommendation.detail,
            subtitle: "",
            comments: recommendation.comments
        )
        switch recommendation.type {
        case .text:
            break
        case .place:
            cell.setupForViewing(
                recommendation.tagString,
                title: recommendation.placeName,
                subtitle: recommendation.placeAddress,
                comments: recommendation.comments
            )
            break
        case .url:
            cell.setupForViewing(
                recommendation.tagString,
                title: recommendation.urlTitle,
                subtitle: recommendation.urlSubtitle,
                comments: recommendation.comments
            )
            break
        }
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button1 = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            let deletedRecommendation: UserRecommendation = USER.myRecommendations.removeAtIndex(indexPath.row)
            FBNetworkDAO.instance.deleteUserRecommendation(deletedRecommendation, callback: nil)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            tableView.endUpdates()
        })
        //89.8, 25.5, 32.9
        button1.backgroundColor = UIColor(red: 0.898, green: 0.255, blue: 0.329, alpha: 0.5)//(.colorFromHex(0xE54154)
        let button2 = UITableViewRowAction(style: .Default, title: "Edit", handler: { (action, indexPath) in
            let recommendation: UserRecommendation = USER.myRecommendations[indexPath.row]
            self.navigationController?.pushViewController(NewRecommendationFormViewController(newRecommendation: recommendation.newRecommendation(), type: .EDIT), animated: true)
        })
        //93.7, 53.7, 26.7
        button2.backgroundColor = UIColor(red: 0.937, green: 0.537, blue: 0.267, alpha: 0.5)//.colorFromHex(0xEF8944)
        return [button1, button2]
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
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let recommendation = USER.myRecommendations[indexPath.row]
        switch recommendation.type {
        case .text:
            break
        case .place:
            let URLString: String?
            if recommendation.placeName.containsString("°") {
                URLString = "https://www.google.com/maps/place/\(recommendation.placeName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()))/@\(recommendation.latitude),\(recommendation.longitude),17z"
            } else {
                URLString = "https://www.google.com/maps/place/\(recommendation.placeName.stringByReplacingOccurrencesOfString(" ", withString: "+"))/@\(recommendation.latitude),\(recommendation.longitude),17z"
            }
            if URLString != nil {
                if let URL: NSURL = NSURL(string: URLString!) {
                    UIApplication.sharedApplication().openURL(URL)
                }
            }
            break
        case .url:
            if let URL: NSURL = NSURL(string: recommendation.detail) {
                UIApplication.sharedApplication().openURL(URL)
            }
            break
        }
    }
}




























































