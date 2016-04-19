//
//  LoadingViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/22/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleMaps

class LoadingView: UIView {
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

class LoadingViewController: UIViewController {
    
    override func loadView() {
        view = LoadingView()
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBarHidden = false
        navigationController?.toolbarHidden = false
        
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationController?.toolbar.barTintColor = CommonUI.toolbarLightColor
    }
    
    override func viewDidAppear(animated: Bool) {
        view.setNeedsDisplay()
        /* Facebook */
        if FBSDKAccessToken.currentAccessToken() == nil {
            navigationController?.pushViewController(FacebookLoginViewController(), animated: false)
        } else {
            User.instance
            CommonUI.instance
            FBNetworkDAO.instance.postFacebookTokenAndAuthenticate({
                FacebookNetworkDAO.instance.getFacebookData({ (successful) in
                    FBNetworkDAO.instance.getFriends({
                        FBNetworkDAO.instance.getRecommendationsForUser({
                            FBNetworkDAO.instance.getQueries({

                                for recommendation: Recommendation in User.instance.recommendations {
                                    if recommendation.type == .place {
                                        NSOperationQueue.mainQueue().addOperationWithBlock {
                                            GMSPlacesClient.sharedClient().lookUpPlaceID(recommendation.detail, callback: { (place: GMSPlace?, error: NSError?) in
                                                if error != nil {
                                                    NSLog("\(error!.description)")
                                                } else {
                                                    if let place = place {
                                                        recommendation.placeName = place.name
                                                        recommendation.placeAddress = place.formattedAddress
                                                    }
                                                }
                                            })
                                        }
                                    }
                                }
                                
                                for query: Query in User.instance.queryHistory.queries {
                                    if let solutions = query.solutions {
                                        for solution: Solution in solutions {
                                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                                GMSPlacesClient.sharedClient().lookUpPlaceID(solution.detail, callback: { (place: GMSPlace?, error: NSError?) in
                                                    if error != nil {
                                                        NSLog("\(error!.description)")
                                                    } else {
                                                        if let place = place {
                                                            solution.placeName = place.name
                                                            solution.placeAddress = place.formattedAddress
                                                        }
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                                
                                self.navigationController?.pushViewController(MainScreenViewController(), animated: false)
                            })
                        })
                        
                    })
                })
            })            
        }
    }
    
}
