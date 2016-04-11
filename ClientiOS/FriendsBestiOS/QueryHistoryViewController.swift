//
//  TestViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/12/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class QueryHistoryView: UITableView {
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

class QueryHistoryViewController: UITableViewController {
    
    override func loadView() {
        view = QueryHistoryView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    }
    
    override func viewDidLoad() {
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
        
        User.instance.queryHistoryUpdatedClosure = {
            [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        FBNetworkDAO.instance.getQueries()
        
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        navigationController?.navigationBar.barTintColor = CommonUI.navbarGrayColor
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor

        setToolbarItems()
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
        return User.instance.queryHistory.queries.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO: learn about reuseIdentifier
        let cell: QueryHistoryTableViewCell = QueryHistoryTableViewCell(
            tags: User.instance.queryHistory.queries[indexPath.row].tags,
            style: .Default,
            reuseIdentifier: nil)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let query: Query = User.instance.queryHistory.queries[indexPath.row]
        navigationController?.pushViewController(SolutionsViewController(tags: query.tags), animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // TODO: Implement deletion and possibly custom delete control
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let query = User.instance.queryHistory.queries[indexPath.row]
        FBNetworkDAO.instance.deleteQuery(query.ID)
        User.instance.queryHistory.deleteQueryByID(query.ID)
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        tableView.endUpdates()
    }
}













