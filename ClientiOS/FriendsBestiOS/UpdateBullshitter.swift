//
//  UpdateBullshitter.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/9/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class UpdateBullshitter {
    
    static let instance: UpdateBullshitter = UpdateBullshitter()
    
    private var timer: Timer? = nil
    
    private init() {
        self.timer = Timer(timesPerSecond: 1/5, closure: { () -> Void in
//            self.checkForNewRecommendations()
            FBNetworkDAO.instance.getPrompts()
        })
        timer?.startTimer()
    }
    
    private func checkForNewRecommendations() {
        for query in User.instance.queryHistory.queries {
            FBNetworkDAO.instance.getQuerySolutions(query.ID)
        }
    }
    
    
}