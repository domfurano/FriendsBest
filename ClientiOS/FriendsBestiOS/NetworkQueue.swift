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
    
    private var queue: [NetworkTask] = []
    private var executing: Bool = false
    private var timer: Timer? = nil
    
    private init() {
        self.timer = Timer(timesPerSecond: 8, closure: { () -> Void in
            if !self.executing && self.queue.count > 0 {
                self.executing = true;
                let task = self.queue.last!
                task.task()
                NSLog("Executing network request: " + task.description)
            }
        })
    }
    
    func push(task: NetworkTask) {
        self.queue.append(task)
        if self.timer!.stopped {
            self.timer!.startTimer()
        }
    }
    
    func enqueue(task: NetworkTask) {
        self.queue.insert(task, atIndex: 0)
        NSLog("Enqueueing network request: " + task.description)
        if self.timer!.stopped {
            self.timer!.startTimer()
        }
    }
    
    func dequeue() {
        assert(self.queue.count > 0)
        let task = self.queue.removeLast()        
        NSLog("Dequeueing network request: " + task.description)
        if self.queue.count == 0 {
            self.timer!.cancelTimer()
        }
        self.executing = false
    }
    
    func tryAgain() {
        self.executing = false
    }
}





































