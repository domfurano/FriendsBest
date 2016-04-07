//
//  FriendsViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/29/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit


class FriendsListViewController: UITableViewController {
    
    let smallProfilePicture: UIImageView = CommonUI.smallProfilePicture!
    
    override func loadView() {
        view = GradientTableView()
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
        title = "Facebook Friends"
        tableView.separatorStyle = .None
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        navigationController?.navigationBar.barTintColor = CommonUI.navbarBlueColor
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
        
        setToolbarItems()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.instance.friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friend: Friend = User.instance.friends[indexPath.row]
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "friendCell")
        cell.textLabel?.text = friend.name
        cell.imageView?.image = friend.squarePicture
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
        
        smallProfilePicture.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        smallProfilePicture.contentMode = .ScaleAspectFit
        let profileButton: UIButton = UIButton(type: UIButtonType.Custom)
        profileButton.frame = smallProfilePicture.frame
        profileButton.layer.masksToBounds = true
        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
        profileButton.addSubview(smallProfilePicture)
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
