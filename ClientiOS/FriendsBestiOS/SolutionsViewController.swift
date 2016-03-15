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

class SolutionsViewController: UITableViewController {

    var queryID: Int?
    var tags: [String] = []
    
    convenience init(tags: [String]) {
        self.init()

        self.queryID = User.instance.queryHistory.getQueryFromTags(tags)?.ID;
        self.tags = tags
        
        User.instance.querySolutionsUpdatedClosure = {
            [weak self] (queryID: Int) -> Void in
            
            if self?.queryID == nil {
                self?.queryID = queryID
            }
            
            self?.tableView.reloadData()
        }
    }
    
    override func loadView() {
        view = SolutionsView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        
        /* Tableview datasource and delegate */        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLoad() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: FAKFontAwesome.chevronLeftIconWithSize(32.0).imageWithSize(CGSize(width: 32.0, height: 32.0)),
            style: .Plain,
            target: self,
            action: Selector("back")
        )
        title = "Solutions"
        tableView.separatorStyle = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.queryID != nil {
            FBNetworkDAO.instance.getQuerySolutions(self.queryID!)
        }
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        if self.queryID != nil {
            if let solutionCount = User.instance.queryHistory.getQueryByID(queryID!)?.solutions?.count {
                return solutionCount
            } else {
                return 0
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return SolutionsTagCell(tags: tags, style: .Default, reuseIdentifier: nil)
        } else {
            let cell: SolutionCell = SolutionCell(detail: User.instance.queryHistory.getQueryByID(queryID!)!.solutions![indexPath.row].detail, style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
            if self.queryID != nil {
//                cell.textLabel?.text = User.instance.queryHistory.getQueryByID(queryID!)!.solutions![indexPath.row].detail
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        
        if self.queryID != nil {
            let detail: String = User.instance.queryHistory.getQueryByID(queryID!)!.solutions![indexPath.row].detail
            navigationController?.pushViewController(SolutionDetailViewController(title: detail, queryID: self.queryID!, solutionIndex: indexPath.row), animated: true)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
}
