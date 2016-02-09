//
//  Queue.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/6/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

class Queue<T> {
    private var first: Node<T>? = nil
    private var last: Node<T>? = nil
    
    func enqueue(item: T) -> Void {
        if self.first == nil {
            self.last = Node(item: item)
            self.first = self.last
        } else {
            self.last!.next = Node(item: item)
            self.last = self.last!.next
        }
    }
    
    func dequeue() -> T? {
        if self.first != nil {
            let item: T = first!.item
            self.first = self.first!.next
            return item
        }
        return nil
    }
}

class Node<T> {
    var item: T
    var next: Node?
    
    init(item: T) {
        self.item = item
    }
}
