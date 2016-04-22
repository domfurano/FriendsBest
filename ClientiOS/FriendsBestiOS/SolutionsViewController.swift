//
//  QueryResultsViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/18/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

// TODO: Query no longer possiblility of being nil!!!

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
    let solutionCellID: String = "solutionCell"
    
    convenience init(query: Query?, tags: [String]) {
        self.init()
        self.QUERY = query
    }
    
    override func loadView() {
        tableView = SolutionsView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        
//        User.instance.closureNewSolution = { (forQuery: Query, index: Int) in
//            if self.QUERY.ID == forQuery.ID {
//                self.tableView.beginUpdates()
//                self.tableView.insertRowsAtIndexPaths([NSIndexPath(index: index)], withRowAnimation: .Left)
//                self.tableView.endUpdates()
//                self.refreshControl?.endRefreshing()
//            }
//        }
    }
    
    override func viewDidLoad() {
        
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
        
        /* NECESSARY FOR DYNAMIC CELL HEIGHT */
        tableView.estimatedRowHeight =  128.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.registerClass(SolutionCell.self, forCellReuseIdentifier: solutionCellID)
        
        let leftBBitem: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.nbBackChevron,
            style: .Plain,
            target: self,
            action: #selector(SolutionsViewController.back)
        )
        leftBBitem.tintColor = UIColor.colorFromHex(0xABB4BA)
        
        self.navigationItem.leftBarButtonItem = leftBBitem
        title = "Solutions"
        tableView.separatorStyle = .None
        
        /* Refresh Control */
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.colorFromHex(0x9BE887)
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(SolutionsViewController.refreshData), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = true
        
        navigationController?.navigationBar.barTintColor = UIColor.colorFromHex(0xdedede)
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Proxima Nova Cond", size: 28.0)!,
            NSForegroundColorAttributeName: UIColor.blackColor()
        ]
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Proxima Nova Cond", size: 28.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
    }
    
    func refreshData() {
        if QUERY != nil {
            refreshControl?.beginRefreshing()
            FBNetworkDAO.instance.getQuerySolutions(QUERY!, callback: {
                self.refreshControl?.endRefreshing()
            })
        }
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
            return QUERY!.solutions.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = SolutionsTagCell(tags: QUERY!.tagString.componentsSeparatedByString(" "), style: .Default, reuseIdentifier: nil)
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else {
            let cell: SolutionCell = tableView.dequeueReusableCellWithIdentifier(solutionCellID) as! SolutionCell
            let solution: Solution = QUERY!.solutions[indexPath.row]
            cell.titleLabel.text = solution.detail
            switch solution.type {
            case .text:
                break
            case .place:
                cell.titleLabel.text = solution.placeName!
                cell.subtitleLabel.text = solution.placeAddress!
                break
            case .url:
                cell.titleLabel.text = solution.urlTitle
                cell.subtitleLabel.text = solution.urlSubtitle
                break
            }
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        navigationController?.pushViewController(SolutionDetailViewController(solution: QUERY!.solutions[indexPath.row]), animated: true)
    }
}
