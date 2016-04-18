//
//  Timer.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/3/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

class Timer {
    private var timesPerSecond: Double
    private var closure: () -> Void
    private var timer: dispatch_source_t?
    var stopped: Bool {
        get {
            return timer == nil
        }
    }    
    
    init(timesPerSecond: Double, closure: () -> Void) {
        self.timesPerSecond = timesPerSecond
        self.closure = closure
        self.timer = nil
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
            dispatch_source_set_timer(self.timer!, dispatch_time(DISPATCH_TIME_NOW, 0), UInt64((1.0 / self.timesPerSecond) * Double(NSEC_PER_SEC)), NSEC_PER_SEC / 10)
            dispatch_source_set_event_handler(self.timer!, closure)
            dispatch_resume(self.timer!)
        }
    }
    
    func cancelTimer() {
        if self.timer != nil {
            dispatch_source_cancel(self.timer!)
            self.timer = nil
        }
    }
}
