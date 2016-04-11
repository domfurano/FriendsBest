//
//  YourRecommendationsViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/24/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class YourRecommendationsView: UITableView {
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

class YourRecommendationsViewController: UITableViewController {
    
    override func loadView() {
        view = YourRecommendationsView()
    }
    
    override func viewDidLoad() {
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
        
        User.instance.userRecommendationsFetchedClosure = {
            self.tableView.reloadData()
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
    }
    
    override func viewWillAppear(animated: Bool) {
        FBNetworkDAO.instance.getRecommendationsForUser()
        
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        navigationController?.navigationBar.barTintColor = CommonUI.fbGreen
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
        
        setToolbarItems()
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /* Toolbar */
    
    func setToolbarItems() {
        let homeButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.home_image,
            style: .Plain,
            target: self,
            action: #selector(YourRecommendationsViewController.homeButtonPressed)
        )
        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
        
        let profileButton: UIButton = UIButton(type: .Custom)
        profileButton.frame = CGRect(x: 0, y: 0, width: 32.0, height: 32.0)
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        CommonUI.instance.setUIButtonWithFacebookProfileImage(profileButton)
        profileButton.addTarget(
            self,
            action: #selector(YourRecommendationsViewController.profileButtonPressed),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.fa_plus_square_image,
            style: .Plain,
            target: self,
            action: #selector(YourRecommendationsViewController.newRecommendationButtonPressed)
        )
        newRecommendationButton.tintColor = CommonUI.fbGreen
        
        toolbarItems = [homeButton, CommonUI.flexibleSpace, profileBBItem, CommonUI.flexibleSpace, newRecommendationButton]
    }
    
    func homeButtonPressed() {
        for viewController: UIViewController in navigationController!.viewControllers {
            if viewController.isKindOfClass(MainScreenViewController) {
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
    
    func profileButtonPressed() {
        navigationController?.popViewControllerAnimated(true)
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    func newRecommendationButtonPressed() {
        return
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.instance.recommendations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "yourRecCell")
        let rec: Recommendation = User.instance.recommendations[indexPath.row]
        cell.textLabel?.text = rec.detail
        cell.detailTextLabel?.text = rec.comment
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        let recommendation = User.instance.recommendations[indexPath.row]
//        FBNetworkDAO.instance.deleteRecommendation(recommendation.ID)
//        User.instance.recommendations.removeAtIndex(indexPath.row)
//        tableView.beginUpdates()
//        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
//        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button1 = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            let recommendation = User.instance.recommendations[indexPath.row]
            FBNetworkDAO.instance.deleteRecommendation(recommendation.ID)
            User.instance.recommendations.removeAtIndex(indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            tableView.endUpdates()
        })
        button1.backgroundColor = UIColor.redColor()
        let button2 = UITableViewRowAction(style: .Default, title: "Edit", handler: { (action, indexPath) in
            print("button2 pressed!")
        })
        button2.backgroundColor = UIColor.blueColor()
        return [button1, button2]
    }
}
