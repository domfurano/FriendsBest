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

class SolutionDetailViewController: UITableViewController {
    
    var TITLE: String?
    var queryID: Int?
    var solutionIndex: Int?
    
    convenience init(title: String, queryID: Int, solutionIndex: Int) {
        self.init()
        
        self.TITLE = title
        self.queryID = queryID
        self.solutionIndex = solutionIndex
    }
    
    override func loadView() {
        view = SolutionDetailView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLoad() {
        tableView.rowHeight = 100.0 // Hacky alpha demo crap
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.instance.queryHistory.getQueryByID(queryID!)!.solutions![solutionIndex!].recommendations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: nil)
        let recommendation: Recommendation = User.instance.queryHistory.getQueryByID(queryID!)!.solutions![solutionIndex!].recommendations[indexPath.row]
        cell.textLabel?.text = recommendation.friend.name
        cell.detailTextLabel?.text = recommendation.comment
        cell.detailTextLabel?.numberOfLines = 10 // Hackity hack
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
