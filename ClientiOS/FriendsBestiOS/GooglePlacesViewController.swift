//
//  GooglePlacesViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/3/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import GoogleMaps

class GooglePlacesViewController: UIViewController {
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRectMake(0, 65.0, 350.0, 45.0))
        
        subView.addSubview((searchController?.searchBar)!)
        self.view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
    }
}

// Handle the user's selection.
extension GooglePlacesViewController: GMSAutocompleteResultsViewControllerDelegate {
    internal func resultsController(resultsController: GMSAutocompleteResultsViewController,
        didAutocompleteWithPlace place: GMSPlace) {
            self.searchController?.active = false
            // Do something with the selected place.
            print("Place name: ", place.name)
            print("Place address: ", place.formattedAddress)
            print("Place attributions: ", place.attributions)
    }
    
    internal func resultsController(resultsController: GMSAutocompleteResultsViewController,
        didFailAutocompleteWithError error: NSError){
            // TODO: handle the error.
            print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    internal func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    internal func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}
