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
import PINCache

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
                FBNetworkDAO.instance.getRecommendationsForUser({
                    for userRecommendation: UserRecommendation in User.instance.myRecommendations {
                        if userRecommendation.type == .place {
                            GooglePlace.loadPlace(userRecommendation.detail, callback: { (successful: Bool, place: GooglePlace?) in
                                if successful {
                                    userRecommendation.placeName = place!.name
                                    userRecommendation.placeAddress = place!.formattedAddress == nil ? "" : place!.formattedAddress!
                                } else {
                                    NSLog("GOOGLE PLACE ERROR!!!")
                                }
                            })
                        }
                    }
                    FBNetworkDAO.instance.getQueries({
                        for query: Query in User.instance.myQueries {
                            for solution: Solution in query.solutions {
                                if solution.type == .place {
                                    GooglePlace.loadPlace(solution.detail, callback: { (successful: Bool, place: GooglePlace?) in
                                        if successful {
                                            solution.placeName = place!.name
                                            solution.placeAddress = place!.formattedAddress == nil ? "" : place!.formattedAddress!
                                        } else {
                                            NSLog("GOOGLE PLACE ERROR!!!")
                                        }
                                    })
                                }
                            }
                        }
                        FacebookNetworkDAO.instance.getFacebookData({ (successful) in
                            FBNetworkDAO.instance.getFriends({
                                self.navigationController?.pushViewController(MainScreenViewController(), animated: false)
                            })
                        })
                    })
                    
                })
            })
        }
    }
    
}
