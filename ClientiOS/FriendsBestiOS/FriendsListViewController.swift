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
        
        /* NECESSARY FOR DYNAMIC CELL HEIGHT */
        tableView.estimatedRowHeight =  128.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        /* Refresh Control */
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.colorFromHex(0x869ECC)
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(FriendsListViewController.refreshData), forControlEvents: .ValueChanged)
        
        USER.closureFriendsNew = { [weak self] in
            self?.tableView.reloadData()
        }
        USER.closureFriendMutingSet = { [weak self] in
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return USER.myFriends.count
    }
    
    static let cellSize: CGFloat = 32.0
    let unmutedImageView: UIImageView = UIImageView(image: FAKFontAwesome.volumeUpIconWithSize(cellSize).imageWithSize(CGSize(width: cellSize, height: cellSize)))
    let mutedImageView: UIImageView = UIImageView(image: FAKFontAwesome.volumeOffIconWithSize(cellSize).imageWithSize(CGSize(width: cellSize, height: cellSize)))
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friend: Friend = USER.myFriends[indexPath.row]
        let cell: FriendCell = FriendCell()
        cell.setupCellForDisplay(friend.smallRoundedPicture.image!, name: friend.name, muteIcon: unmutedImageView.image!)
        if let muted = friend.muted {
            if muted {
                cell.setupCellForDisplay(friend.smallRoundedPicture.image!, name: friend.name, muteIcon: mutedImageView.image!)
            }
            cell.muteButtonSelectedDelegate = { [weak self] in
                FBNetworkDAO.instance.setMutingForFriend(friend, mute: !muted, callback: { [weak self] in
                    self?.tableView.reloadData()
                    })
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let friend: Friend = USER.myFriends[indexPath.row]
        if let muted = friend.muted {
            let friend: Friend = USER.myFriends[indexPath.row]
            FBNetworkDAO.instance.setMutingForFriend(friend, mute: !muted, callback: nil)
        }
    }
    
    //    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        let friend: Friend = USER.myFriends[indexPath.row]
    //        if let muted = friend.muted {
    //            let friend: Friend = USER.myFriends[indexPath.row]
    //            FBNetworkDAO.instance.setMutingForFriend(friend, mute: !muted, callback: nil)
    //        }
    //    }
    
    /* Toolbar */
    
    //    func setToolbarItems() {
    //        let homeButton: UIBarButtonItem = UIBarButtonItem(
    //            image: CommonUI.home_image,
    //            style: .Plain,
    //            target: self,
    //            action: #selector(ProfileViewController.homeButtonPressed)
    //        )
    //        homeButton.tintColor = UIColor.colorFromHex(0x646d77)
    //
    //        let profileButton: UIButton = UIButton(type: .Custom)
    //        profileButton.frame = CGRect(x: 0, y: 0, width: 32.0, height: 32.0)
    //        profileButton.layer.masksToBounds = true
    //        profileButton.layer.cornerRadius = profileButton.bounds.width / 2
    //        CommonUI.instance.setUIButtonWithFacebookProfileImage(profileButton)
    //        profileButton.addTarget(
    //            self,
    //            action: #selector(ProfileViewController.profileButtonPressed),
    //            forControlEvents: UIControlEvents.TouchUpInside
    //        )
    //        let profileBBItem: UIBarButtonItem = UIBarButtonItem(customView: profileButton)
    //
    //
    //        let newRecommendationButton: UIBarButtonItem = UIBarButtonItem(
    //            image: CommonUI.fa_plus_square_image,
    //            style: .Plain,
    //            target: self,
    //            action: #selector(ProfileViewController.newRecommendationButtonPressed)
    //        )
    //        newRecommendationButton.tintColor = CommonUI.fbGreen
    //
    //        toolbarItems = [homeButton, CommonUI.flexibleSpace, profileBBItem, CommonUI.flexibleSpace, newRecommendationButton]
    //    }
    
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
