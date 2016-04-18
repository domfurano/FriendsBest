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
    
    var placePicker: GMSPlacePicker?
    
    override func loadView() {
        view = YourRecommendationsView()
    }
    
    override func viewDidLoad() {
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
        
        /* NECESSARY FOR DYNAMIC CELL HEIGHT */
        tableView.estimatedRowHeight =  128.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        User.instance.userRecommendationsFetchedClosure = {
            self.refreshControl?.endRefreshing()
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
        tableView.separatorStyle = .SingleLine
        
        /* Refresh Control */
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.colorFromHex(0x9BE887)
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(YourRecommendationsViewController.refreshData), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = true
        
        navigationController?.navigationBar.barTintColor = CommonUI.fbGreen
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
        
//        setToolbarItems()
    }
    
    func refreshData() {
        refreshControl?.beginRefreshing()
        FBNetworkDAO.instance.getRecommendationsForUser(nil)
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
        let recommendation: Recommendation = User.instance.recommendations[indexPath.row]
        
        let cell: YourRecommendationTableViewCell = YourRecommendationTableViewCell(recommendation: recommendation)
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button1 = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            let recommendation = User.instance.recommendations[indexPath.row]
            FBNetworkDAO.instance.deleteRecommendation(recommendation.ID, callback: nil)
            User.instance.recommendations.removeAtIndex(indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            tableView.endUpdates()
        })
        button1.backgroundColor = UIColor.colorFromHex(0xE54154)
        let button2 = UITableViewRowAction(style: .Default, title: "Edit", handler: { (action, indexPath) in
            let recommendation: Recommendation = User.instance.recommendations[indexPath.row]
            self.navigationController?.pushViewController(NewRecommendationFormViewController(recommendation: recommendation.userRecommendation(), type: .EDIT), animated: true)
        })
        button2.backgroundColor = UIColor.colorFromHex(0xEF8944)
        return [button1, button2]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let recommendation = User.instance.recommendations[indexPath.row]
        switch recommendation.type {
        case .text:
            break
        case .place:
            GMSPlacesClient.sharedClient().lookUpPlaceID(recommendation.detail, callback: { (place: GMSPlace?, error: NSError?) in
                if error == nil {
                    if let place = place {
                        let offset = 0.001
                        let center: CLLocationCoordinate2D = place.coordinate
                        let northEast = CLLocationCoordinate2DMake(center.latitude + offset, center.longitude + offset)
                        let southWest = CLLocationCoordinate2DMake(center.latitude - offset, center.longitude - offset)
                        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                        
                        let config = GMSPlacePickerConfig(viewport: viewport)
                        self.placePicker = GMSPlacePicker(config: config)
                        self.placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) in
                            
                        })
                    }
                }
            })
            break
        case .url:
            self.navigationController?.pushViewController(WebViewController(recommendation: recommendation.userRecommendation()), animated: true)
            break
        }
    }
}




























































