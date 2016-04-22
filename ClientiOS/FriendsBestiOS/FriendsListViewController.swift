//
//  FriendsViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/29/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit


class FriendsListViewController: UITableViewController {
    
    override func loadView() {
        tableView = GradientTableView()
    }
    
    override func viewDidLoad() {
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
        
        /* Refresh Control */
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.colorFromHex(0x869ECC)
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(FriendsListViewController.refreshData), forControlEvents: .ValueChanged)
        
        User.instance.closureNewFriend = { (index: Int) in
            self.tableView.beginUpdates()
            let indexPath: NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.endUpdates()
        }
        
        let leftBBitem: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.nbBackChevron,
            style: .Plain,
            target: self,
            action: #selector(YourRecommendationsViewController.back)
        )
        leftBBitem.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = leftBBitem
        title = "Facebook Friends"
        tableView.separatorStyle = .None
    }
    
    func refreshData() {
        self.refreshControl?.beginRefreshing()
        FBNetworkDAO.instance.getFriends({
            self.refreshControl?.endRefreshing()
        })
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = true
        
        navigationController?.navigationBar.barTintColor = CommonUI.navbarBlueColor
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
        
//        setToolbarItems()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.instance.myFriends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friend: Friend = User.instance.myFriends[indexPath.row]
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "friendCell")
        cell.textLabel?.text = friend.name
        cell.imageView?.image = CommonUI.defaultProfileImage
        cell.imageView?.image = CommonUI.instance.getFacebookProfileUIImageView(
            friend.facebookID,
            facebookSize: CommonUI.FacbookImageSize.square,
            closure: { (indexPath: AnyObject?) in
                self.tableView.reloadRowsAtIndexPaths([indexPath as! NSIndexPath], withRowAnimation: .Fade)
            },
            payload: indexPath
        ).image
//        cell.imageView?.image = CommonUI.instance.getFacebookProfileUIImageView(friend.facebookID, size: .square, closure: { (indexPath: AnyObject?)
//            cell.setNeedsDisplay()
//        }, payload: indexPath).image
        cell.userInteractionEnabled = false
        return cell
    }
    
    /* Toolbar */
    
    func setToolbarItems() {
        let homeButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.home_image,
            style: .Plain,
            target: self,
            action: #selector(ProfileViewController.homeButtonPressed)
        )
        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
        
        let profileButton: UIButton = UIButton(type: .Custom)
        profileButton.frame = CGRect(x: 0, y: 0, width: 32.0, height: 32.0)
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        CommonUI.instance.setUIButtonWithFacebookProfileImage(profileButton)
        profileButton.addTarget(
            self,
            action: #selector(ProfileViewController.profileButtonPressed),
            forControlEvents: UIControlEvents.TouchUpInside
        )
        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        
        
        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.fa_plus_square_image,
            style: .Plain,
            target: self,
            action: #selector(ProfileViewController.newRecommendationButtonPressed)
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
        return
    }
    
    func newRecommendationButtonPressed() {
        return
    }
    
    
    
    
    
}
