//
//  SolutionDetailViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/18/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class SolutionDetailView: UITableView {
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

class SolutionDetailViewController: UITableViewController {
    
    var SOLUTION: Solution!
    
    
    convenience init(solution: Solution) {
        self.init()
        
        self.SOLUTION = solution
    }
    
    override func loadView() {
        view = SolutionDetailView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight =  128.0
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.separatorStyle = .None
        
        tableView.registerClass(SolutionDetailTableViewCell.self, forCellReuseIdentifier: "SolutionDetailCell")
        
        let button: UIButton = UIButton(type: .Custom)
        button.setImage(CommonUI.nbBackChevron, forState: .Normal)
        button.addTarget(
            self,
            action: #selector(SolutionDetailViewController.back),
            forControlEvents: .TouchUpInside
        )
        button.sizeToFit()
        button.tintColor = UIColor.whiteColor()
        let leftBBItem: UIBarButtonItem = UIBarButtonItem(customView: button)
        
        leftBBItem.tintColor = UIColor.whiteColor()
        leftBBItem.title = SOLUTION.detail
        navigationItem.leftBarButtonItem = leftBBItem
        
        /* Refresh Control */
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.colorFromHex(0x949494)
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(SolutionDetailViewController.refreshData), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = true
        
        navigationController?.navigationBar.barTintColor = CommonUI.sdNavbarBgColor
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SolutionDetailViewController.contentSizeCategoryChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    func refreshData() {
        refreshControl?.beginRefreshing()
        FBNetworkDAO.instance.getQuerySolutions(SOLUTION.query!) {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    // This function will be called when the Dynamic Type user setting changes (from the system Settings app)
    func contentSizeCategoryChanged(notification: NSNotification)
    {
        tableView.reloadData()
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return SOLUTION.recommendations.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let recommendation: FriendRecommendation = SOLUTION.recommendations[indexPath.row]
        if indexPath.section == 0 {
            let cell: SolutionDetailHeaderTableViewCell = SolutionDetailHeaderTableViewCell(recommendation: recommendation)
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else {
            let cell: SolutionDetailTableViewCell = SolutionDetailTableViewCell(recommendation: recommendation)
            switch recommendation.solution!.type {
            case .text:
                break
            case .place:
                GooglePlace.loadPlace(recommendation.solution!.detail, callback: { (place) in
                    cell.setupForViewing(place.name)
                })
                break
            case .url:
                if let url: NSURL = NSURL(string: recommendation.solution!.detail) {
                    if let host: String = url.host {
                        cell.setupForViewing(host)
                    }
                }
                break
            }
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        }
    }
}











