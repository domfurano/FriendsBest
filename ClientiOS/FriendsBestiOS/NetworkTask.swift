//
//  NetworkTask.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/4/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class NetworkTask {
    
    let task: () -> Void
    let description: String
    
    init(task: () -> Void, description: String) {
        self.task = task
        self.description = description
    }
}
