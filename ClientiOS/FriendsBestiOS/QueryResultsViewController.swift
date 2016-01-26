//
//  QueryResultsViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/18/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class QueryResultsViewController: UITableViewController, QuerySolutionsUpdatedDelegate {
    
    var TITLE: String?
    var queryID: Int?
    
    convenience init(title: String, queryID: Int) {
        self.init()
        self.TITLE = title
        self.queryID = queryID
    }
    
    override func loadView() {
        view = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        
        /* Tableview datasource and delegate */        
        tableView.dataSource = self
        tableView.delegate = self
        
        User.instance.querySolutionsUpdatedDelegate = self
    }
    
    override func viewDidLoad() {        
        title = TITLE
    }
    
    override func viewWillAppear(animated: Bool) {
        NetworkDAO.instance.getQuerySolutions(self.queryID!)
    }
    
    func querySolutionsUpdated(forQueryID queryID: Int) {
        if self.queryID == queryID {
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let solutionCount = User.instance.queryHistory.getQueryByID(queryID!)?.solutions?.count {
            return solutionCount
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        let solution: Solution = User.instance.queryHistory.getQueryByID(queryID!)!.solutions![indexPath.row]
        cell.textLabel?.text = solution.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let solution: Solution = User.instance.queryHistory.getQueryByID(queryID!)!.solutions![indexPath.row]
        
        navigationController?.pushViewController(SolutionDetailViewController(title: solution.name, queryID: self.queryID!, solutionIndex: indexPath.row), animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
