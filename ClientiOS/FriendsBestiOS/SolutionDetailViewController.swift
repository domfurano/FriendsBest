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
        
        let button: UIButton = UIButton(type: .Custom)
        button.setImage(CommonUI.nbBackChevron, forState: .Normal)
//        button.setTitle(SOLUTION!.detail, forState: .Normal)
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
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = true
        
        navigationController?.navigationBar.barTintColor = CommonUI.sdNavbarBgColor
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
        if indexPath.section == 0 {
            let cell: UITableViewCell = UITableViewCell(style: .Default, reuseIdentifier: "main")
            cell.textLabel?.text = SOLUTION.detail
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.backgroundColor = CommonUI.sdNavbarBgColor
            cell.userInteractionEnabled = false
            return cell
        } else {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "detail")
            let recommendation: Recommendation = SOLUTION.recommendations[indexPath.row]
            cell.textLabel?.text = recommendation.friend.name
            cell.textLabel?.numberOfLines = 0 // 0 means unlimited
            cell.detailTextLabel?.text = recommendation.comment
            cell.detailTextLabel?.numberOfLines = 0
            cell.imageView?.image = UIImage.roundedRectImageFromImage(recommendation.friend.squarePicture)
            cell.userInteractionEnabled = false
            return cell
        }
    }
}











