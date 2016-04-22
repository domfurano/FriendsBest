//
//  UpdateBullshitter.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/9/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class Updater {
    
    static let instance: Updater = Updater()
    
    private var timer: Timer!
    private var gettingPrompts: Bool = false
    
    func STAHP () {
        self.timer.cancelTimer()
    }
    
    func start() {
        self.timer.startTimer()
    }
    
    private init() {
        self.timer = Timer(timesPerSecond: 1, closure: { () -> Void in
            if User.instance.myPrompts.count < 1 {
                if !self.gettingPrompts {
                    self.gettingPrompts = true
                    FBNetworkDAO.instance.getPrompts({
                        self.gettingPrompts = false
                    })
                }
            }
        })
        timer.startTimer()
    }
    
    
    
//    private func checkForNewRecommendations() {
//        for query in User.instance.queryHistory.queries {
//            FBNetworkDAO.instance._getQuerySolutions(query.ID)
//        }
//    }
    
    
}