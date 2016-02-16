//
//  TestViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/12/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class QueryHistoryViewController: UITableViewController {
    
    override func loadView() {
        view = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    }
    
    override func viewDidLoad() {
//        let context: CGContext = UIGraphicsGetCurrentContext()!
//        CGContextClearRect(context, self.view.bounds)
//        
//        CommonUIElements.drawGradientForContext(
//            [
//                UIColor.colorFromHex(0xfefefe).CGColor,
//                UIColor.colorFromHex(0xc8ced0).CGColor
//            ],
//            frame: self.view.frame,
//            context: context
//        )
        
        /* Navigation bar */
        
        title = "Search History"        
        
        /* Tableview datasource and delegate */
        
        tableView.dataSource = self
        tableView.delegate = self
        
        User.instance.queryHistoryUpdatedClosure = {
            [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        /* Toolbar */
        navigationController?.toolbarHidden = true
        
        NetworkDAO.instance.getQueries()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO
        return User.instance.queryHistory.queries.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO: learn about reuseIdentifier
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.textLabel?.text = User.instance.queryHistory.queries[indexPath.row].tags.joinWithSeparator(" ")
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let query: Query = User.instance.queryHistory.queries[indexPath.row]
        navigationController?.pushViewController(SolutionsViewController(tags: query.tags), animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}













