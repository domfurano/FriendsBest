//
//  QueryResultsViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/18/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class SolutionsView: UITableView {
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

class SolutionsViewController: UITableViewController {

    var QUERY: Query?
    
    convenience init(tags: [String]) {
        self.init()
        
        self.QUERY = User.instance.queryHistory.getQueryFromTags(tags)
        
        User.instance.querySolutionsUpdatedClosure = {
            [weak self] (queryID: Int) -> Void in
            if self?.QUERY == nil {
                let query = User.instance.queryHistory.getQueryByID(queryID)!
                let incomingTags: [String] = query.tags
                if User.instance.queryHistory.tagsEqual(tags, tag2: incomingTags) {
                    self?.QUERY = query
                }
            }
            
            if self?.QUERY!.ID == queryID {
                self?.tableView.reloadData()
            }
        }
    }
    
    override func loadView() {
        view = SolutionsView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    }
    
    override func viewDidLoad() {
        
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
        
        let leftBBitem: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.nbBackChevron,
            style: .Plain,
            target: self,
            action: #selector(SolutionsViewController.back)
        )
        leftBBitem.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = leftBBitem
        title = "Solutions"
        tableView.separatorStyle = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        FBNetworkDAO.instance.getQuerySolutions(QUERY!.ID)
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        navigationController?.navigationBar.barTintColor = CommonUI.navbarGrayColor
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if QUERY == nil {
            return 0
        } else {
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if QUERY == nil {
            return 0
        }
        
        if section == 0 {
            return 1
        }
        
        if let solutionCount = QUERY!.solutions?.count {
            return solutionCount
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return SolutionsTagCell(tags: QUERY!.tags, style: .Default, reuseIdentifier: nil)
        } else {
            let cell: SolutionCell = SolutionCell(detail: QUERY!.solutions![indexPath.row].detail, style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        navigationController?.pushViewController(SolutionDetailViewController(solution: QUERY!.solutions![indexPath.row]), animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}
