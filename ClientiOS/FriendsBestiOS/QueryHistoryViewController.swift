//
//  TestViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/12/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class QueryHistoryViewController: UITableViewController, QueryHistoryUpdatedDelegate {
    
    override func loadView() {
        view = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Navigation bar */
        
        title = "Search History"
        
        
        /* Tableview datasource and delegate */
        
        tableView.dataSource = self
        tableView.delegate = self
        
        User.instance.queryHistoryUpdatedDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Toolbar */
        navigationController?.toolbarHidden = true
        
        NetworkDAO.instance.getQueries()
    }
    
    /* Delegate implementations */
    func queryHistoryUpdated() {
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO
        return User.instance.queryHistory.queries.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO: learn about reuseIdentifier
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = User.instance.queryHistory.queries[indexPath.row].tags.joinWithSeparator(" ")
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let query: Query = User.instance.queryHistory.queries[indexPath.row]
        let queryTitle: String = query.tags.joinWithSeparator(" ")
        navigationController?.pushViewController(QueryResultsViewController(title: queryTitle, queryID: query.ID), animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}