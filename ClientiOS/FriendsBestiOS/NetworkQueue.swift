//
//  NetworkQueue.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/2/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class NetworkQueue {
    
    static var instance: NetworkQueue = NetworkQueue()
    
    private var queue: Queue<NetworkTask> = Queue<NetworkTask>()
    private var executing: Bool = false
    private var timer: Timer? = nil
    private var retries: Int = 5
    
    private init() {        
        self.timer = Timer(timesPerSecond: 8, closure: { () -> Void in
//            NSLog("Timer firing!")
            if !self.executing && self.queue.count > 0 {
                self.executing = true;
                let task = self.queue.first!
                task.item.task()
                NSLog("Executing network request: " + task.item.description)
            }
        })
    }
    
    func push(task: NetworkTask) {
        self.queue.push(task)
        if self.timer!.stopped {
            self.timer!.startTimer()
        }
    }
    
    func enqueue(task: NetworkTask) {
        self.queue.enqueue(task)
//        NSLog("Enqueueing network request: " + task.description)
        if self.timer!.stopped {
            self.timer!.startTimer()
        }
    }
    
    func dequeue() {
        assert(self.queue.count > 0)
        self.queue.dequeue()
//        let task: NetworkTask = self.queue.dequeue()!
//        NSLog("Dequeueing network request: " + task.description)
        if self.queue.count == 0 {
            self.timer!.cancelTimer()
        }
        self.executing = false
    }
    
    func tryAgain() {
        self.executing = false
        self.retries -= 1
        if self.retries == 0 {
            self.dequeue()
        }
        // TODO: Slow down timer until task is dequeued
    }
}





































