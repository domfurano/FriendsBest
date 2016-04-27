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
    
    private var promptTimer: Timer!
    private var queryTimer: Timer!
    private var gettingPrompts: Bool = false
    
    func STAHP () {
        self.promptTimer.cancelTimer()
        self.queryTimer.cancelTimer()
    }
    
    func start() {
        self.promptTimer.startTimer()
        self.queryTimer.startTimer()
    }
    
    private init() {
        self.promptTimer = Timer(timesPerSecond: 1.0, closure: { () -> Void in
            if USER.myPrompts.count < 1 {
                if !self.gettingPrompts {
                    self.gettingPrompts = true
                    FBNetworkDAO.instance.getPrompts({
                        self.gettingPrompts = false
                    })
                }
            }
        })
        promptTimer.startTimer()
        
        self.queryTimer = Timer(timesPerSecond: 1.0 / 6.0, closure: { () -> Void in
            FBNetworkDAO.instance._getQueries(true, callback: {

            })
        })
        queryTimer.startTimer()
    }
    
    deinit {
        STAHP()
    }
}
