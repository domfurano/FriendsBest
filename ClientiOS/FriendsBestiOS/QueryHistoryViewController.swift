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
        /* Background gradient */
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)
        
        CommonUIElements.drawGradientForContext(
            [
                UIColor.colorFromHex(0xfefefe).CGColor,
                UIColor.colorFromHex(0xc8ced0).CGColor
            ],
            frame: frame,
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

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: FAKFontAwesome.chevronLeftIconWithSize(32.0).imageWithSize(CGSize(width: 32.0, height: 32.0)),
            style: .Plain,
            target: self,
            action: Selector("back")
        )
        

        
        setToolbarItems()
        
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
            action: Selector("homeButtonPressed")
        )
        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
        
        let fa_plus_square: FAKFontAwesome = FAKFontAwesome.plusSquareIconWithSize(32)
        let fa_plus_square_image: UIImage = fa_plus_square.imageWithSize(CGSize(width: 32, height: 32))
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
            image: fa_plus_square_image,
            style: .Plain,
            target: self,
            action: Selector("newRecommendationButtonPressed")
        )
        newRecommendationButton.tintColor = UIColor.colorFromHex(0x00d735)
        
        toolbarItems = [homeButton, flexibleSpace, profileBBItem, flexibleSpace, newRecommendationButton]
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Toolbar */
//        navigationController?.toolbarHidden = true
        
        FBNetworkDAO.instance.getQueries()
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













