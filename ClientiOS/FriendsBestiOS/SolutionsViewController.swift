//
//  QueryResultsViewController.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/18/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

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

class SolutionsViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    var filteredSolutions: [Solution] = []
    var searching: Bool {
        return searchController.active && searchController.searchBar.text != ""
    }
    
    var QUERY: Query?
    let solutionCellID: String = "solutionCell"
    var loading: Bool {
        return QUERY == nil
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    convenience init(query: Query?, tags: [String]) {
        self.init()
        self.QUERY = query
    }
    
    override func loadView() {
        tableView = SolutionsView(frame: CGRectZero, style: UITableViewStyle.Grouped)
    }
    
    override func viewDidLoad() {
        
        /* Tableview datasource and delegate */
        tableView.dataSource = self
        tableView.delegate = self
        
        /* NECESSARY FOR DYNAMIC CELL HEIGHT */
        tableView.estimatedRowHeight =  128.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        definesPresentationContext = true
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.barTintColor = UIColor.colorFromHex(0xdedede)
        searchController.searchBar.translucent = false
        searchController.searchBar.autocapitalizationType = .None
        tableView.tableHeaderView = searchController.searchBar
        
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
        
        addRefreshControl()
        
        
        USER.closureQueryNew = { [weak self] (query) in
            if self != nil {
                if self!.loading {
                    self!.QUERY = query
                    self!.addRefreshControl()
                }
                self!.refreshControl?.endRefreshing()
                self!.tableView.reloadData()
            }
        }
        USER.closureSolutionsFetchedForQuery = { [weak self] (query) in
            if self != nil {
                if self!.loading {
                    self!.QUERY = query
                    self!.addRefreshControl()
                }
                self!.refreshControl?.endRefreshing()
                self!.tableView.reloadData()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SolutionsViewController.showAlert),
            name: "notifications",
            object: nil
        )
    }
    
    func addRefreshControl() {
        /* Refresh Control */
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = UIColor.colorFromHex(0xf0f0f0)
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(SolutionsViewController.refreshData), forControlEvents: .ValueChanged)
    }
    
    func removeRefreshControl() {
        refreshControl = nil
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if loading {
            refreshControl?.beginRefreshing()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Proxima Nova Cond", size: 28.0)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        searchController.active = false
    }
    
    func showAlert(notification: NSNotification) {
        if !loading {
            for query: Query in USER.myQueries {
                if query.ID == QUERY!.ID {
                    QUERY = query
                }
            }
        }
        tableView.reloadData()
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.setShowsCancelButton(true, animated: false)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if loading {
            return
        }
        
        filteredSolutions.removeAll(keepCapacity: true)
        for solution: Solution in QUERY!.solutions {
            if  solution.placeName.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
                || solution.detail.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
                || solution.urlTitle.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString) {
                filteredSolutions.append(solution)
            }
        }
        
        tableView.reloadData()
    }
    
    func refreshData() {
        if !loading {
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
        if loading {
            return 1
        } else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 0
        } else {
            if section == 0 {
                return 1
            } else if section == 1 {
                if searching {
                    return filteredSolutions.count
                } else {
                    return QUERY!.solutions.count
                }
            } else {
                return 1
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if loading {
            return "loading..."
        } else {
            if section == 0 {
                return "Keywords"
            } else if section == 1 {
                if QUERY!.solutions.isEmpty {
                    return "No solutions"
                } else {
                    return "Solutions"
                }
            }
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = SolutionsTagCell(tags: QUERY!.tagString.componentsSeparatedByString(" "), style: .Default, reuseIdentifier: nil)
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else if indexPath.section == 1 {
            let cell: SolutionCell = tableView.dequeueReusableCellWithIdentifier(solutionCellID) as! SolutionCell
            
            let solution: Solution
            if searching {
                solution = filteredSolutions[indexPath.row]
            } else {
                solution = QUERY!.solutions[indexPath.row]
            }
            
            solution.closureSolutionUpdated = { [weak self] in
                self?.tableView.reloadData()
            }
            cell.titleLabel.text = solution.detail
            switch solution.type {
            case .text:
                break
            case .place:
                cell.titleLabel.text = solution.placeName
                cell.subtitleLabel.text = solution.placeAddress
                break
            case .url:
                cell.titleLabel.text = solution.urlTitle
                cell.subtitleLabel.text = solution.urlSubtitle
                break
            }
            cell.setupForViewing(solution.notificationCount > 0)
            return cell
        } else {
            let fbShareCell = FacebookShareCell()
            fbShareCell.setupForViewing(QUERY!.tagString)
            return fbShareCell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        } else if indexPath.section == 1 {
            navigationController?.pushViewController(SolutionDetailViewController(solution: QUERY!.solutions[indexPath.row]), animated: true)
        }
    }
}
