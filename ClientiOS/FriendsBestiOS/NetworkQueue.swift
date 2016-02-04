//
//  NetworkQueue.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/2/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class NetworkQueue {
    
    static let instance: NetworkQueue = NetworkQueue()
    
    private var queue: [NSURLSessionDataTask] = []
    private var executing: Bool = false
    private var timer: Timer? = nil
    
    private init() {
        self.timer = Timer(timesPerSecond: 2, closure: { () -> Void in
            if !self.executing && self.queue.count > 0 {
                NSLog("Executing network request..." + (self.queue.last?.description)!)
                self.executing = true;
                self.queue.last?.resume()
            }
        })
        self.timer!.startTimer()
    }
    
    func push(task: NSURLSessionDataTask) {
        self.queue.append(task)
    }
    
    func enqueue(task: NSURLSessionDataTask) {
        self.queue.insert(task, atIndex: 0)
    }
    
    func dequeue() {
        assert(self.queue.count > 0)
        self.queue.removeLast()
        self.executing = false
    }
    
    func tryAgain() {
        self.executing = false
    }
}





































