//
//  QueryResultsViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/18/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class SolutionsViewController: UITableViewController {
    
//    var TITLE: String?
    var queryID: Int?
    var tags: [String]?
    
    convenience init(tags: [String]) {//(title: String, queryID: Int) {
        self.init()
//        self.TITLE = title
//        self.queryID = queryID
        self.tags = tags
        self.queryID = User.instance.queryHistory.getQueryFromTags(tags)?.ID;
    }
    
    override func loadView() {
        view = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        
        /* Tableview datasource and delegate */        
        tableView.dataSource = self
        tableView.delegate = self
        
        User.instance.querySolutionsUpdatedClosure = {
            [weak self] (queryID: Int) -> Void in
            
            if self?.queryID == nil {
                self?.queryID = queryID
            }
            
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {        
//        title = TITLE
        title = tags?.joinWithSeparator(" ")
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.queryID != nil {
            FBNetworkDAO.instance.getQuerySolutions(self.queryID!)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        if self.queryID != nil {
            let solution: Solution = User.instance.queryHistory.getQueryByID(queryID!)!.solutions![indexPath.row]
            cell.textLabel?.text = solution.detail
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.queryID != nil {
            let solution: Solution = User.instance.queryHistory.getQueryByID(queryID!)!.solutions![indexPath.row]
            navigationController?.pushViewController(SolutionDetailViewController(title: solution.detail, queryID: self.queryID!, solutionIndex: indexPath.row), animated: true)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
